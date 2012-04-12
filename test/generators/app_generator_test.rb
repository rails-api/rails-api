require 'generators/generators_test_helper'
require 'rails-bare/generators/rails/app/app_generator'

class AppGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::AppGenerator

  arguments [destination_root]

  def test_skeleton_is_created
    run_generator

    default_files.each { |path| assert_file path }
  end

  def test_bare_modified_files
    run_generator

    assert_file "Gemfile" do |content|
      assert_match(/gem 'rails-bare'/, content)
      assert_no_match(/gem 'coffee-rails'/, content)
      assert_no_match(/gem 'sass-rails'/, content)
    end
    assert_file "app/controllers/application_controller.rb", /ActionController::Bare/
    assert_file "config/application.rb", /Rails::BareApplication/
  end

  private

  def default_files
    %w(.gitignore
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
       doc
       lib
       lib/tasks
       lib/assets
       log
       script/rails
       test/fixtures
       test/functional
       test/integration
       test/performance
       test/unit
       vendor
       vendor/assets
       tmp/cache
       tmp/cache/assets)
  end
end
