require 'test_helper'

class UrlForBareController < ActionController::Bare
  def one; end
  def two; end
end

class UrlForBareTest < ActionController::TestCase
  tests UrlForBareController

  def setup
    super
    @request.host = 'www.example.com'
  end

  def test_url_for
    get :one
    assert_equal "http://www.example.com/url_for_bare/one", @controller.url_for
  end
end
