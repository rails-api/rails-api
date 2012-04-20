require 'fileutils'

module Rails
  class Railtie
    remove_const :ABSTRACT_RAILTIES
    ABSTRACT_RAILTIES = %w(Rails::Railtie Rails::Engine Rails::Application Rails::ApiApplication)
  end

  module Base
    Bootstrap = ::Rails::Application::Bootstrap
    Configuration = ::Rails::Application::Configuration
    Finisher = ::Rails::Application::Finisher
    Railties = ::Rails::Application::Railties
    RoutesReloader = ::Rails::Application::RoutesReloader

    module ClassMethods
      def inherited(base)
        raise "You cannot have more than one Rails::Application" if Rails.application
        super
        Rails.application = base.instance
        Rails.application.add_lib_to_load_path!
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        alias_method :build_middleware_stack, :app
      end
    end

    attr_accessor :assets, :sandbox
    alias_method :sandbox?, :sandbox
    attr_reader :reloaders

    delegate :default_url_options, :default_url_options=, :to => :routes

    def initialize
      super
      @initialized = false
      @reloaders   = []
    end

    # This method is called just after an application inherits from Rails::Application,
    # allowing the developer to load classes in lib and use them during application
    # configuration.
    #
    #   class MyApplication < Rails::Application
    #     require "my_backend" # in lib/my_backend
    #     config.i18n.backend = MyBackend
    #   end
    #
    # Notice this method takes into consideration the default root path. So if you
    # are changing config.root inside your application definition or having a custom
    # Rails application, you will need to add lib to $LOAD_PATH on your own in case
    # you need to load files in lib/ during the application configuration as well.
    def add_lib_to_load_path! #:nodoc:
      path = config.root.join('lib').to_s
      $LOAD_PATH.unshift(path) if File.exists?(path)
    end

    def require_environment! #:nodoc:
      environment = paths["config/environment"].existent.first
      require environment if environment
    end

    # Reload application routes regardless if they changed or not.
    def reload_routes!
      routes_reloader.reload!
    end

    def routes_reloader #:nodoc:
      @routes_reloader ||= Application::RoutesReloader.new
    end

    # Returns an array of file paths appended with a hash of directories-extensions
    # suitable for ActiveSupport::FileUpdateChecker API.
    def watchable_args
      files, dirs = config.watchable_files.dup, config.watchable_dirs.dup

      ActiveSupport::Dependencies.autoload_paths.each do |path|
        dirs[path.to_s] = [:rb]
      end

      [files, dirs]
    end

    # Initialize the application passing the given group. By default, the
    # group is :default but sprockets precompilation passes group equals
    # to assets if initialize_on_precompile is false to avoid booting the
    # whole app.
    def initialize!(group=:default) #:nodoc:
      raise "Application has been already initialized." if @initialized
      run_initializers(group, self)
      @initialized = true
      self
    end

    # Load the application and its railties tasks and invoke the registered hooks.
    # Check <tt>Rails::Railtie.rake_tasks</tt> for more info.
    def load_tasks(app=self)
      initialize_tasks
      super
      self
    end

    # Load the application console and invoke the registered hooks.
    # Check <tt>Rails::Railtie.console</tt> for more info.
    def load_console(app=self)
      initialize_console
      super
      self
    end

    # Stores some of the Rails initial environment parameters which
    # will be used by middlewares and engines to configure themselves.
    def env_config
      @env_config ||= super.merge({
        "action_dispatch.parameter_filter" => config.filter_parameters,
        "action_dispatch.secret_token" => config.secret_token,
        "action_dispatch.show_exceptions" => config.action_dispatch.show_exceptions,
        "action_dispatch.show_detailed_exceptions" => config.consider_all_requests_local,
        "action_dispatch.logger" => Rails.logger,
        "action_dispatch.backtrace_cleaner" => Rails.backtrace_cleaner
      })
    end

    # Returns the ordered railties for this application considering railties_order.
    def ordered_railties #:nodoc:
      @ordered_railties ||= begin
        order = config.railties_order.map do |railtie|
          if railtie == :main_app
            self
          elsif railtie.respond_to?(:instance)
            railtie.instance
          else
            railtie
          end
        end

        all = (railties.all - order)
        all.push(self)   unless all.include?(self)
        order.push(:all) unless order.include?(:all)

        index = order.index(:all)
        order[index] = all
        order.reverse.flatten
      end
    end

    def initializers #:nodoc:
      Application::Bootstrap.initializers_for(self) +
      super +
      Application::Finisher.initializers_for(self)
    end

    def config #:nodoc:
      @config ||= Application::Configuration.new(find_root_with_flag("config.ru", Dir.pwd))
    end

    def to_app
      self
    end

    def helpers_paths #:nodoc:
      config.helpers_paths
    end

    def call(env)
      env["ORIGINAL_FULLPATH"] = build_original_fullpath(env)
      super(env)
    end

  protected

    def reload_dependencies?
      config.reload_classes_only_on_change != true || reloaders.map(&:updated?).any?
    end

    def initialize_tasks #:nodoc:
      self.class.rake_tasks do
        require "rails/tasks"
        task :environment do
          $rails_rake_task = true
          require_environment!
        end
      end
    end

    def initialize_console #:nodoc:
      require "pp"
      require "rails/console/app"
      require "rails/console/helpers"
    end

    def build_original_fullpath(env)
      path_info    = env["PATH_INFO"]
      query_string = env["QUERY_STRING"]
      script_name  = env["SCRIPT_NAME"]

      if query_string.present?
        "#{script_name}#{path_info}?#{query_string}"
      else
        "#{script_name}#{path_info}"
      end
    end
  end
end
