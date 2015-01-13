require 'rails/version'
require 'rails-api/version'
require 'rails-api/action_controller/api'
require 'rails-api/application'

module Rails
  module API
    def self.rails3?
      Rails::VERSION::MAJOR == 3
    end
  end
end
