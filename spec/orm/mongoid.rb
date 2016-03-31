require 'mongoid/version'

Mongoid.configure do |config|
  config.load!('spec/support/mongoid.yml')
  config.use_utc = true
  config.include_root_in_json = true
end

RSpec.configure do |config|
  config.before(:suite) do
  	Mongoid.purge!
  end
end