require 'generators/generators_test_helper'
require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper

  arguments %w(product_line title:string product:belongs_to user:references)
  setup :copy_routes

  def test_scaffold_on_invoke
    run_generator

    # Model
    assert_file "app/models/product_line.rb", /class ProductLine < ActiveRecord::Base/
    assert_file "test/#{generated_test_unit_dir}/product_line_test.rb", /class ProductLineTest < ActiveSupport::TestCase/
    assert_file "test/fixtures/product_lines.yml"

    if rails3?
      assert_migration "db/migrate/create_product_lines.rb",
        /belongs_to :product/,
        /add_index :product_lines, :product_id/,
        /references :user/,
        /add_index :product_lines, :user_id/
    else
      assert_migration "db/migrate/create_product_lines.rb",
        /belongs_to :product, index: true/,
        /references :user, index: true/
    end

    # Route
    assert_file "config/routes.rb" do |content|
      assert_match(/resources :product_lines, except: \[:new, :edit\]$/, content)
      assert_no_match(/resource :product_lines$/, content)
    end

    # Controller
    assert_file "app/controllers/product_lines_controller.rb" do |content|
      assert_match(/class ProductLinesController < ApplicationController/, content)
      assert_no_match(/respond_to/, content)

      assert_match(/before_action :set_product_line, only: \[:show, :update, :destroy\]/, content)

      assert_instance_method :index, content do |m|
        assert_match(/@product_lines = ProductLine\.all/, m)
        assert_match(/render json: @product_lines/, m)
      end

      assert_instance_method :show, content do |m|
        assert_match(/render json: @product_line/, m)
      end

      assert_instance_method :create, content do |m|
        assert_match(/@product_line = ProductLine\.new\(product_line_params\)/, m)
        assert_match(/@product_line\.save/, m)
        assert_match(/@product_line\.errors/, m)
      end

      assert_instance_method :update, content do |m|
        assert_match(/@product_line = ProductLine\.find\(params\[:id\]\)/, m)
        if rails3?
          assert_match(/@product_line\.update_attributes\(product_line_params\)/, m)
        else
          assert_match(/@product_line\.update\(product_line_params\)/, m)
        end
        assert_match(/@product_line\.errors/, m)
      end

      assert_instance_method :destroy, content do |m|
        assert_match(/@product_line\.destroy/, m)
      end

      assert_instance_method :set_product_line, content do |m|
        assert_match(/@product_line = ProductLine\.find\(params\[:id\]\)/, m)
      end

      assert_instance_method :product_line_params, content do |m|
        assert_match(/params\.require\(:product_line\)\.permit\(:title, :product_id, :user_id\)/, m)
      end
    end

    assert_file "test/#{generated_test_functional_dir}/product_lines_controller_test.rb" do |test|
      assert_match(/class ProductLinesControllerTest < ActionController::TestCase/, test)
      if rails3?
        assert_match(/post :create, product_line: \{ title: @product_line.title \}/, test)
        assert_match(/put :update, id: @product_line, product_line: \{ title: @product_line.title \}/, test)
      else
        assert_match(/post :create, product_line: \{ product_id: @product_line.product_id, title: @product_line.title, user_id: @product_line.user_id \}/, test)
        assert_match(/put :update, id: @product_line, product_line: \{ product_id: @product_line.product_id, title: @product_line.title, user_id: @product_line.user_id \}/, test)
      end
      assert_no_match(/assert_redirected_to/, test)
    end

    # Views
    %w(index edit new show _form).each do |view|
      assert_no_file "app/views/product_lines/#{view}.html.erb"
    end
    assert_no_file "app/views/layouts/product_lines.html.erb"

    # Helpers
    assert_no_file "app/helpers/product_lines_helper.rb"
    assert_no_file "test/#{generated_test_unit_dir}/helpers/product_lines_helper_test.rb"

    # Assets
    assert_no_file "app/assets/stylesheets/scaffold.css"
    assert_no_file "app/assets/stylesheets/product_lines.css"
    assert_no_file "app/assets/javascripts/product_lines.js"
  end
end
