require 'rails-api/version'
require 'rails-api/action_controller/api'
require 'rails-api/application'

module Rails
  module API
    def self.rails4?
      Rails::VERSION::MAJOR == 4
    end
  end
end
