require 'test_helper'

class RedirectToBareController < ActionController::Bare
  def one
    redirect_to :action => "two"
  end

  def two; end
end

class RedirectToBareTest < ActionController::TestCase
  tests RedirectToBareController

  def test_redirect_to
    get :one
    assert_response :redirect
    assert_equal "http://test.host/redirect_to_bare/two", redirect_to_url
  end
end
