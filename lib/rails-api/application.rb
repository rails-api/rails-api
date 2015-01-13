require 'rails/application'
require 'rails-api/public_exceptions'
require 'rails-api/application/default_rails_four_middleware_stack'

module Rails
  class Application < Engine
    alias_method :rails_default_middleware_stack, :default_middleware_stack

    def default_middleware_stack
      if Rails::API.rails3?
        rails3_stack
      else
        DefaultRailsFourMiddlewareStack.new(self, config, paths).build_stack
      end
    end

    private

    def setup_generators!
      generators = config.generators

      generators.templates.unshift File::expand_path('../templates', __FILE__)
      generators.resource_route = :api_resource_route

      generators.hide_namespace "css"

      generators.rails({
        :helper => false,
        :assets => false,
        :stylesheets => false,
        :stylesheet_engine => nil,
        :template_engine => nil
      })
    end

    ActiveSupport.on_load(:before_configuration) do
      config.api_only = true
      setup_generators!
    end
    
    def check_serve_static_files
      if Rails::VERSION::MAJOR >= 5 || (Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR > 1)
        config.serve_static_files
      else
        config.serve_static_assets
      end
    end

    def rails3_stack
      ActionDispatch::MiddlewareStack.new.tap do |middleware|
        if rack_cache = config.action_controller.perform_caching && config.action_dispatch.rack_cache
          require "action_dispatch/http/rack_cache"
          middleware.use ::Rack::Cache, rack_cache
        end

        if config.force_ssl
          require "rack/ssl"
          middleware.use ::Rack::SSL, config.ssl_options
        end

        if config.action_dispatch.x_sendfile_header.present?
          middleware.use ::Rack::Sendfile, config.action_dispatch.x_sendfile_header
        end
        

        if check_serve_static_files
          middleware.use ::ActionDispatch::Static, paths["public"].first, config.static_cache_control
        end
        
        middleware.use ::Rack::Lock unless config.allow_concurrency
        middleware.use ::Rack::Runtime
        middleware.use ::Rack::MethodOverride unless config.api_only
        middleware.use ::ActionDispatch::RequestId
        middleware.use ::Rails::Rack::Logger, config.log_tags # must come after Rack::MethodOverride to properly log overridden methods
        middleware.use ::ActionDispatch::ShowExceptions, config.exceptions_app || Rails::API::PublicExceptions.new(Rails.public_path)
        middleware.use ::ActionDispatch::DebugExceptions
        middleware.use ::ActionDispatch::RemoteIp, config.action_dispatch.ip_spoofing_check, config.action_dispatch.trusted_proxies

        unless config.cache_classes
          app = self
          middleware.use ::ActionDispatch::Reloader, lambda { app.reload_dependencies? }
        end

        middleware.use ::ActionDispatch::Callbacks
        middleware.use ::ActionDispatch::Cookies unless config.api_only

        if !config.api_only && config.session_store
          if config.force_ssl && !config.session_options.key?(:secure)
            config.session_options[:secure] = true
          end
          middleware.use config.session_store, config.session_options
          middleware.use ::ActionDispatch::Flash
        end

        middleware.use ::ActionDispatch::ParamsParser
        middleware.use ::ActionDispatch::Head
        middleware.use ::Rack::ConditionalGet
        middleware.use ::Rack::ETag, "no-cache"

        if !config.api_only && config.action_dispatch.best_standards_support
          middleware.use ::ActionDispatch::BestStandardsSupport, config.action_dispatch.best_standards_support
        end
      end
    end
  end
end
