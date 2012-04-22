require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

Rails::Generators::AppGenerator.source_paths.unshift(
  File.expand_path('../../../../templates/rails/app', __FILE__)
)

class Rails::AppBuilder
  undef tmp
  undef vendor
end
