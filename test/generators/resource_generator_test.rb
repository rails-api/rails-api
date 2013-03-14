require 'generators/generators_test_helper'
require 'rails/generators/rails/resource/resource_generator'

class ResourceGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  arguments %w(account)
  setup :copy_routes

  def test_resource_routes_are_added
    run_generator

    assert_file "config/routes.rb" do |route|
      assert_match(/resources :accounts, except: \[:new, :edit\]$/, route)
      assert_no_match(/resources :accounts$/, route)
    end
  end
end
