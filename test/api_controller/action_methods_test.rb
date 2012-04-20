require 'test_helper'

class ActionMethodsApiController < ActionController::API
  def one; end
  def two; end
  hide_action :two
end

class ActionMethodsApiTest < ActionController::TestCase
  tests ActionMethodsApiController

  def test_action_methods
    assert_equal Set.new(%w(one)),
                 @controller.class.action_methods,
                 "#{@controller.controller_path} should not be empty!"
  end
end
