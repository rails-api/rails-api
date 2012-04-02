require 'rails/engine'
require 'rails/monkey_patches/application'

module Rails
  class BareApplication < Engine
    include Base

    def default_middleware_stack
      ActionDispatch::MiddlewareStack.new.tap do |middleware|
        if rack_cache = config.action_controller.perform_caching && config.action_dispatch.rack_cache
          require "action_dispatch/http/rack_cache"
          middleware.use ::Rack::Cache, rack_cache
        end

        if config.force_ssl
          middleware.use ::ActionDispatch::SSL, config.ssl_options
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
  end
end
