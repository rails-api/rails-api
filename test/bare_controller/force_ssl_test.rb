require 'test_helper'

class ForceSSLBareController < ActionController::Bare
  force_ssl

  def one; end
  def two
    head :ok
  end
end

class ForceSSLBareTest < ActionController::TestCase
  tests ForceSSLBareController

  def test_redirects_to_https
    get :two
    assert_response 301
    assert_equal "https://test.host/force_ssl_bare/two", redirect_to_url
  end
end
