# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'rails'
require 'rails/test_help'
require 'rails-api'

def app
  unless defined?(@@app)
    @@app = Class.new(Rails::Application)
    @@app.class_eval do
      config.active_support.deprecation = :stderr
      config.generators do |c|
        c.orm :active_record, :migration => true,
                              :timestamps => true

        c.test_framework :test_unit, :fixture => true,
                                     :fixture_replacement => nil

        c.integration_tool :test_unit
        c.performance_tool :test_unit
      end

      def self.name
        'TestApp'
      end
    end
  end
  @@app
end

app.routes.append do
  match ':controller(/:action)'
end
app.routes.finalize!

module ActionController
  class API
    include app.routes.url_helpers
  end
end

app.load_generators

Rails.logger = Logger.new("/dev/null")
