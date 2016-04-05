# Rails and RSpec integration
require 'spec_helper'

# RSpec config
RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
end

