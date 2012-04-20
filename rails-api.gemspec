# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rails-api/version'

Gem::Specification.new do |gem|
  gem.name          = "rails-api"
  gem.version       = Rails::API::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.summary       = %q{Rails for API only Applications}
  gem.description   = %q{Rails::API is a subset of a normal Rails application,
                         created for applications that don't require all
                         functionality that a complete Rails application provides}
  gem.licenses      = ['MIT']

  gem.authors       = ["Santiago Pastorino and Carlos Antonio da Silva"]
  gem.email         = ["<santiago@wyeworks.com>", "<carlosantoniodasilva@gmail.com>"]
  gem.homepage      = "https://github.com/spastorino/rails-api"

  gem.required_rubygems_version = '>= 1.3.6'

  gem.files         = Dir['README.md', 'bin/**/*', 'lib/**/*', 'test/**/*']
  gem.test_files    = Dir['test/**/*']
  gem.require_paths = ["lib"]

  gem.bindir        = 'bin'
  gem.executables   = ['rails-api']

  gem.add_runtime_dependency 'actionpack', '>= 3.2.0'
  gem.add_runtime_dependency 'railties', '>= 3.2.0'
  gem.add_runtime_dependency 'tzinfo', '~> 0.3.31'

  gem.add_development_dependency 'rails', '>= 3.2.0'
end
