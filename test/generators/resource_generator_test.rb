require 'generators/generators_test_helper'
require 'rails/generators/rails/resource/resource_generator'

class ResourceGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ResourceGenerator

  arguments %w(account)

  def setup
    super
    copy_routes
  end

  def test_resource_routes_are_added
    run_generator

    assert_file "config/routes.rb" do |route|
      assert_match(/resources :accounts, except: :edit$/, route)
    end
  end
end
