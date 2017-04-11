require 'generators/generators_test_helper'
require 'generators/rails/scope/scope_generator'

class ScopeGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  arguments %w(comment best)
  setup :copy_routes
  setup :copy_controller
  setup :copy_model
  
  def test_scope_route_and_methods_are_added
    run_generator

    # Route
    assert_file "config/routes.rb" do |content|
      assert_match(/get 'best', on: :collection/, content)
    end

    # Controller
    assert_file "app/controllers/comments_controller.rb" do |content|
      assert_match(/def best/, content)
      assert_match(/@comments = Comment.best/, content)
      assert_match(/render json: @comments/, content)
    end

    # Model
    assert_file "app/models/comment.rb" do |content|
      assert_match(/scope :best, -> { all }/, content)
    end
  end
end
