require 'test_helper'
require 'action_controller/railtie'
require 'rack/test'

class OmgController < ActionController::Bare
  def index
    render :text => "OMG"
  end
end

class BareApplicationTest < ActiveSupport::TestCase
  include ::Rack::Test::Methods

  def test_boot_bare_app
    app.initialize!

    get "/omg"
    assert_equal 200, last_response.status
    assert_equal "OMG", last_response.body
  end
end
