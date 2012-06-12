require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Model
  def to_json(options = {})
    { :a => 'b' }.to_json(options)
  end

  def to_xml(options = {})
    { :a => 'b' }.to_xml(options)
  end
end

class RenderersApiController < ActionController::API
  use ActionDispatch::ShowExceptions, Rails::API::PublicExceptions.new(Rails.public_path)

  def one
    render :json => Model.new
  end

  def two
    render :xml => Model.new
  end

  def boom
    raise "boom"
  end
end

class RenderersApiTest < ActionController::TestCase
  tests RenderersApiController

  def test_render_json
    get :one
    assert_response :success
    assert_equal({ :a => 'b' }.to_json, @response.body)
  end

  def test_render_xml
    get :two
    assert_response :success
    assert_equal({ :a => 'b' }.to_xml, @response.body)
  end
end

class RenderExceptionsTest < ActionDispatch::IntegrationTest
  def setup
    @app = RenderersApiController.action(:boom)
  end

  def test_render_json_exception
    get "/fake", {}, 'HTTP_ACCEPT' => 'application/json'
    assert_response :internal_server_error
    assert_equal 'application/json', response.content_type.to_s
    assert_equal({ :status => '500', :error => 'boom' }.to_json, response.body)
  end

  def test_render_xml_exception
    get "/fake", {}, 'HTTP_ACCEPT' => 'application/xml'
    assert_response :internal_server_error
    assert_equal 'application/xml', response.content_type.to_s
    assert_equal({ :status => '500', :error => 'boom' }.to_xml, response.body)
  end

  def test_render_fallback_exception
    get "/fake", {}, 'HTTP_ACCEPT' => 'text/csv'
    assert_response :internal_server_error
    assert_equal 'text/html', response.content_type.to_s
  end
end
