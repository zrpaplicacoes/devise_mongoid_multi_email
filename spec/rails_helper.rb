# Rails and RSpec integration
require 'spec_helper'

# General RSpec config
RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
end

# DSL Helpers
RSpec.configure do |config|
	# Gems includes
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include Rails.application.routes.url_helpers

  # Helpers
  config.include RSpec::Support::UserForm, type: :feature
end

