require 'test_helper'

class ActionMethodsApiController < ActionController::API
  def one; end
  def two; end
  # Rails 5 does not have method hide_action
  if Rails::VERSION::MAJOR < 5
    hide_action :two
  end
end

class ActionMethodsApiTest < ActionController::TestCase
  tests ActionMethodsApiController

  def test_action_methods
    if Rails::VERSION::MAJOR < 5
      assert_equal Set.new(%w(one)),
                  @controller.class.action_methods,
                  "#{@controller.controller_path} should not be empty!"
    else
      assert_equal Set.new(%w(one two)),
                  @controller.class.action_methods,
                  "#{@controller.controller_path} should not be empty!"
    end
  end
end
