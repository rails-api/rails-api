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

class RenderersBareController < ActionController::Bare
  def one
    render :json => Model.new
  end

  def two
    render :xml => Model.new
  end
end

class RenderersBareTest < ActionController::TestCase
  tests RenderersBareController

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
