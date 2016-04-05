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

