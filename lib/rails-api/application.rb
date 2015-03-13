require 'rails/application'
require 'rails-api/public_exceptions'
require 'rails-api/application/default_rails_four_middleware_stack'

module Rails
  class Application < Engine
    alias_method :rails_default_middleware_stack, :default_middleware_stack

    def default_middleware_stack
      DefaultRailsFourMiddlewareStack.new(self, config, paths).build_stack
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
  end
end
