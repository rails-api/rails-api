require 'generators/generators_test_helper'
require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  tests Rails::Generators::ScaffoldGenerator

  arguments %w(product_line title:string product:belongs_to user:references)

  def setup
    super
    copy_routes
  end

  def test_scaffold_on_invoke
    run_generator

    # Model
    assert_file "app/models/product_line.rb", /class ProductLine < ActiveRecord::Base/
    assert_file "test/unit/product_line_test.rb", /class ProductLineTest < ActiveSupport::TestCase/
    assert_file "test/fixtures/product_lines.yml"
    assert_migration "db/migrate/create_product_lines.rb",
      /belongs_to :product/,
      /add_index :product_lines, :product_id/,
      /references :user/,
      /add_index :product_lines, :user_id/

    # Route
    assert_file "config/routes.rb" do |content|
      assert_match(/resources :product_lines, except: :edit$/, content)
      assert_no_match(/resource :product_lines$/, content)
    end

    # Controller
    assert_file "app/controllers/product_lines_controller.rb" do |content|
      assert_match(/class ProductLinesController < ApplicationController/, content)
      assert_no_match(/respond_to/, content)

      assert_instance_method :index, content do |m|
        assert_match(/@product_lines = ProductLine\.all/, m)
      end

      assert_instance_method :show, content do |m|
        assert_match(/@product_line = ProductLine\.find\(params\[:id\]\)/, m)
      end

      assert_instance_method :new, content do |m|
        assert_match(/@product_line = ProductLine\.new/, m)
      end

      assert_instance_method :create, content do |m|
        assert_match(/@product_line = ProductLine\.new\(params\[:product_line\]\)/, m)
        assert_match(/@product_line\.save/, m)
        assert_match(/@product_line\.errors/, m)
      end

      assert_instance_method :update, content do |m|
        assert_match(/@product_line = ProductLine\.find\(params\[:id\]\)/, m)
        assert_match(/@product_line\.update_attributes\(params\[:product_line\]\)/, m)
        assert_match(/@product_line\.errors/, m)
      end

      assert_instance_method :destroy, content do |m|
        assert_match(/@product_line = ProductLine\.find\(params\[:id\]\)/, m)
        assert_match(/@product_line\.destroy/, m)
      end
    end

    assert_file "test/functional/product_lines_controller_test.rb" do |test|
      assert_match(/class ProductLinesControllerTest < ActionController::TestCase/, test)
      assert_match(/post :create, product_line: \{ title: @product_line.title \}/, test)
      assert_match(/put :update, id: @product_line, product_line: \{ title: @product_line.title \}/, test)
      assert_no_match(/assert_redirected_to/, test)
    end

    # Views
    %w(index edit new show _form).each do |view|
      assert_no_file "app/views/product_lines/#{view}.html.erb"
    end
    assert_no_file "app/views/layouts/product_lines.html.erb"

    # Helpers
    assert_no_file "app/helpers/product_lines_helper.rb"
    assert_no_file "test/unit/helpers/product_lines_helper_test.rb"

    # Assets
    assert_no_file "app/assets/stylesheets/scaffold.css"
    assert_no_file "app/assets/javascripts/product_lines.js"
    assert_no_file "app/assets/stylesheets/product_lines.css"
  end
end
