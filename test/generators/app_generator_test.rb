require 'generators/generators_test_helper'
require 'rails-api/generators/rails/app/app_generator'

class AppGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  arguments [destination_root]

  def test_skeleton_is_created
    run_generator

    default_files.each { |path| assert_file path }
    skipped_files.each { |path| assert_no_file path }
  end

  def test_api_modified_files
    run_generator

    assert_file "Gemfile" do |content|
      assert_match(/gem 'rails-api'/, content)
      assert_no_match(/gem 'coffee-rails'/, content)
      assert_no_match(/gem 'jquery-rails'/, content)
      assert_no_match(/gem 'sass-rails'/, content)
    end
    assert_file "app/controllers/application_controller.rb", /ActionController::API/
  end

  private

  def default_files
    files = %W(
      .gitignore
      Gemfile
      Rakefile
      config.ru
      app/controllers
      app/mailers
      app/models
      config/environments
      config/initializers
      config/locales
      db
      lib
      lib/tasks
      lib/assets
      log
      test/fixtures
      test/#{generated_test_functional_dir}
      test/integration
      test/#{generated_test_unit_dir}
    )
    files.concat rails3? ? default_files_rails3 : default_files_rails
    files
  end

  def default_files_rails3
    %w(script/rails)
  end

  def default_files_rails
    %w(bin/bundle bin/rails bin/rake)
  end

  def skipped_files
    %w(vendor/assets
       tmp/cache/assets)
  end
end
