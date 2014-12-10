# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'bundler/setup'
require 'rails'
require 'rails/test_help'
require 'rails-api'

def rails3?
  Rails::API.rails3?
end

class ActiveSupport::TestCase
  def self.app
    @@app ||= Class.new(Rails::Application) do
      config.active_support.deprecation = :stderr
      config.generators do |c|
        c.orm :active_record, :migration => true,
          :timestamps => true

        c.test_framework :test_unit, :fixture => true,
          :fixture_replacement => nil

        c.integration_tool :test_unit
        c.performance_tool :test_unit
      end

      unless rails3?
        config.eager_load = false
        config.secret_key_base = 'abc123'
      end

      def self.name
        'TestApp'
      end
    end
  end

  def app
    self.class.app
  end

  app.routes.append do
    get ':controller(/:action)'
  end
  app.routes.finalize!

  app.load_generators
end

module ActionController
  class API
    include ActiveSupport::TestCase.app.routes.url_helpers
  end
end

Rails.logger = Logger.new("/dev/null")
