ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require 'rspec/rails'
require 'factory_girl_rails'
require 'orm/mongoid'
require 'database_cleaner'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
# Helpers
Dir["#{File.dirname(__FILE__)}/support/helpers/**/*.rb"].each { |f| require f }
# Configurations
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
	config.mock_with :rspec
	config.infer_base_class_for_anonymous_controllers = false
	config.order = "random"
end