require 'test_helper'
require 'rails/generators/test_case'

class Rails::Generators::TestCase
  destination File.expand_path("../../tmp", __FILE__)

  def setup
    mkdir_p destination_root
  end

  def teardown
    rm_rf destination_root
  end

  private

  def copy_routes
    routes = File.expand_path("../fixtures/routes.rb", __FILE__)
    destination = File.join(destination_root, "config")
    FileUtils.mkdir_p(destination)
    FileUtils.cp routes, destination
  end
end
