class ApplicationRecord
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
end
