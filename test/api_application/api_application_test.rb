require 'test_helper'
require 'action_controller/railtie'
require 'rack/test'

class OmgController < ActionController::API
  def index
    render :text => "OMG"
  end
end

class ApiApplicationTest < ActiveSupport::TestCase
  include ::Rack::Test::Methods

  app.initialize!

  def test_boot_api_app
    get "/omg"
    assert_equal 200, last_response.status
    assert_equal "OMG", last_response.body
  end

  def test_api_middleware_stack
    expected_middleware_stack =
      rails4? ? expected_middleware_stack_rails4 : expected_middleware_stack_rails3

    assert_equal expected_middleware_stack, app.middleware.map(&:klass).map(&:name)
  end

  private

  def expected_middleware_stack_rails3
    [
      "ActionDispatch::Static",
      "Rack::Lock",
      "ActiveSupport::Cache::Strategy::LocalCache",
      "Rack::Runtime",
      "ActionDispatch::RequestId",
      "Rails::Rack::Logger",
      "ActionDispatch::ShowExceptions",
      "ActionDispatch::DebugExceptions",
      "ActionDispatch::RemoteIp",
      "ActionDispatch::Reloader",
      "ActionDispatch::Callbacks",
      "ActionDispatch::ParamsParser",
      "ActionDispatch::Head",
      "Rack::ConditionalGet",
      "Rack::ETag"
    ]
  end

  def expected_middleware_stack_rails4
    [
      "ActionDispatch::Static",
      "Rack::Lock",
      "ActiveSupport::Cache::Strategy::LocalCache",
      "Rack::Runtime",
      "ActionDispatch::RequestId",
      "Rails::Rack::Logger",
      "ActionDispatch::ShowExceptions",
      "ActionDispatch::DebugExceptions",
      "ActionDispatch::RemoteIp",
      "ActionDispatch::Reloader",
      "ActionDispatch::Callbacks",
      "ActionDispatch::ParamsParser",
      "Rack::Head",
      "Rack::ConditionalGet",
      "Rack::ETag",
    ]
  end
end
