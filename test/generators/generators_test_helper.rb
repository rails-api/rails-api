require 'test_helper'
require 'rails/generators'

module GeneratorsTestHelper
  def self.included(base)
    base.class_eval do
      destination File.expand_path("../../tmp", __FILE__)
      setup    :prepare_destination
      teardown :remove_destination

      begin
        base.tests Rails::Generators.const_get(base.name.sub(/Test$/, ''))
      rescue
      end
    end
  end

  private

  def copy_routes
    routes = File.expand_path("../fixtures/routes.rb", __FILE__)
    destination = File.join(destination_root, "config")
    FileUtils.mkdir_p(destination)
    FileUtils.cp routes, destination
  end

  def generated_test_unit_dir
    rails4? ? 'models' : 'unit'
  end

  def generated_test_funcional_dir
    rails4? ? 'controllers' : 'functional'
  end

  def remove_destination
    rm_rf destination_root
  end
end
