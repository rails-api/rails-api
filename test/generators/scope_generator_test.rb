require 'generators/generators_test_helper'
require 'rails-api/generators/rails/scope/scope_generator'

class ScopeGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  tests ScopeGenerator
  arguments %w(comment best)

  setup :copy_routes
  setup :copy_controller
  setup :copy_model
  
  def test_scope_route_and_methods_are_added
    run_generator

    assert_file "config/routes.rb" do |content|
      assert_match(/get 'best', on: :collection/, content)
    end

    assert_file "app/controllers/comments_controller.rb" do |content|
      assert_match(/def best/, content)
      assert_match(/@comments = Comment.best/, content)
      assert_match(/render json: @comments/, content)
    end

    assert_file "app/models/comment.rb" do |content|
      assert_match(/scope :best, -> { all }/, content)
    end
  end
end
