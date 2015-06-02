require 'rails/generators'

class ScopeGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :resource_name, type: :string
  argument :scope_name, type: :string

  def generate_scope_route
    resources_do_line = /resources :#{Regexp.quote(group_name)}, except: \[:new, :edit\] do/i
    resources_line = /resources :#{Regexp.quote(group_name)}, except: \[:new, :edit\]+(\s)*(?!.)/i
    in_root do
      inject_into_file 'config/routes.rb', scope_route, after: resources_do_line, verbose: false
      inject_into_file 'config/routes.rb', scope_route_with_do, after: resources_line, verbose: false
    end
  end

  def generate_scope_action
    private_line = /private/i
    in_root do
      inject_into_file "app/controllers/#{group_name}_controller.rb", scope_action, before: private_line, verbose: false
    end
  end

  def generate_scope
    class_line = /class #{resource_name.singularize.camelcase} < ActiveRecord::Base/
    in_root do
      inject_into_file "app/models/#{resource_name.singularize.underscore}.rb", scope, after: class_line, verbose: false
    end
  end

  private

  def group_name
    resource_name.pluralize.underscore
  end

  def scope_route
    "\n    get '#{scope_name.downcase}', on: :collection"
  end

  def scope_route_with_do
    " do\n    get '#{scope_name.downcase}', on: :collection\n  end"
  end

  def scope_action
    "# GET /#{group_name}/#{scope_name.downcase}\n  # GET /#{group_name}/#{scope_name.downcase}.json\n  def #{scope_name.downcase}
    @#{group_name} = #{resource_name.singularize.camelcase}.#{scope_name.downcase}
    \n    render json: @#{group_name}\n  end\n\n  "
  end

  def scope
    "\n  scope :#{scope_name.downcase}, -> { all } #Add your constraints here."
  end
end
