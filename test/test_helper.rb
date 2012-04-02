# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'rails'
require 'rails/test_help'
require 'action_controller/bare'
require 'rails/bare_application'

def app
  @@app ||= Class.new(Rails::BareApplication).tap do |app|
    app.config.active_support.deprecation = :stderr
  end
end

app.routes.append do
  match ':controller(/:action)'
end
app.routes.finalize!

module ActionController
  class Bare
    include app.routes.url_helpers
  end
end

Rails.logger = Logger.new("/dev/null")
