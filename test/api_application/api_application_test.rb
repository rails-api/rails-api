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

  def test_boot_api_app
    app.initialize!

    get "/omg"
    assert_equal 200, last_response.status
    assert_equal "OMG", last_response.body
  end
end
