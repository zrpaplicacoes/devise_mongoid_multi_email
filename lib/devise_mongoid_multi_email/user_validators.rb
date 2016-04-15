module DeviseMongoidMultiEmail
  module UserValidators
    extend ActiveSupport::Concern

    included do
      validates_associated get_devise_email_association
    end

  end
end