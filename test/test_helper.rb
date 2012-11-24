# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'rails'
require 'rails/test_help'
require 'rails-api'

def rails4?
  Rails.version.start_with? '4'
end

def app
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

    if rails4?
      config.eager_load = false
      config.secret_key_base = 'abc123'
    end

    def self.name
      'TestApp'
    end
  end
end

app.routes.append do
  get ':controller(/:action)'
end
app.routes.finalize!

module ActionController
  class API
    include app.routes.url_helpers
  end
end

app.load_generators

Rails.logger = Logger.new("/dev/null")
