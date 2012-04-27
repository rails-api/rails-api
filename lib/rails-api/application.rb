require 'rails/version'
require 'rails/application'

module Rails
  class Application < Engine
    def default_middleware_stack
      ActionDispatch::MiddlewareStack.new.tap do |middleware|
        if rack_cache = config.action_controller.perform_caching && config.action_dispatch.rack_cache
          require "action_dispatch/http/rack_cache"
          middleware.use ::Rack::Cache, rack_cache
        end

        if config.force_ssl
          middleware.use ssl_module, config.ssl_options
        end

        if config.action_dispatch.x_sendfile_header.present?
          middleware.use ::Rack::Sendfile, config.action_dispatch.x_sendfile_header
        end

        if config.serve_static_assets
          middleware.use ::ActionDispatch::Static, paths["public"].first, config.static_cache_control
        end

        middleware.use ::Rack::Lock unless config.allow_concurrency
        middleware.use ::Rack::Runtime
        middleware.use ::ActionDispatch::RequestId
        middleware.use ::Rails::Rack::Logger, config.log_tags # must come after Rack::MethodOverride to properly log overridden methods
        middleware.use ::ActionDispatch::ShowExceptions, config.exceptions_app || ActionDispatch::PublicExceptions.new(Rails.public_path)
        middleware.use ::ActionDispatch::DebugExceptions
        middleware.use ::ActionDispatch::RemoteIp, config.action_dispatch.ip_spoofing_check, config.action_dispatch.trusted_proxies

        unless config.cache_classes
          app = self
          middleware.use ::ActionDispatch::Reloader, lambda { app.reload_dependencies? }
        end

        middleware.use ::ActionDispatch::Callbacks

        middleware.use ::ActionDispatch::ParamsParser
        middleware.use ::ActionDispatch::Head
        middleware.use ::Rack::ConditionalGet
        middleware.use ::Rack::ETag, "no-cache"
      end
    end

    if Rails::VERSION::STRING <= "3.2.3"
      def load_generators(app=self)
        super
        require 'rails/generators/rails/resource/resource_generator'
        Rails::Generators::ResourceGenerator.class_eval do
          def add_resource_route
            return if options[:actions].present?
            route_config =  regular_class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
            route_config << "resources :#{file_name.pluralize}"
            route_config << ", except: :edit"
            route_config << " end" * regular_class_path.size
            route route_config
          end
        end
        self
      end
    end

    private

    def ssl_module
      if defined? ::ActionDispatch::SSL
        ::ActionDispatch::SSL
      else
        require 'rack/ssl'
        ::Rack::SSL
      end
    end

    def setup_generators!
      generators = config.generators

      generators.templates.unshift File::expand_path('../templates', __FILE__)
      if Rails::VERSION::STRING > "3.2.3"
        generators.resource_route = :api_resource_route
      end

      %w(assets css js session_migration).each do |namespace|
        generators.hide_namespace namespace
      end

      generators.rails({
        :assets => false,
        :helper => false,
        :javascripts => false,
        :javascript_engine => nil,
        :stylesheets => false,
        :stylesheet_engine => nil,
        :template_engine => nil
      })
    end

    ActiveSupport.on_load(:before_configuration) do
      setup_generators!
    end
  end
end
