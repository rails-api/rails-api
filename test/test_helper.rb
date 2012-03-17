# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'rails'
require 'rails/test_help'
require 'action_controller/bare'

App = Class.new(Rails::Application)

SharedTestRoutes = ActionDispatch::Routing::RouteSet.new
SharedTestRoutes.draw do
  match ':controller(/:action)'
end

module ActionController
  class TestCase
    setup do
      @routes = SharedTestRoutes
    end
  end
end

module ActionController
  class Bare
    include SharedTestRoutes.url_helpers
  end
end
