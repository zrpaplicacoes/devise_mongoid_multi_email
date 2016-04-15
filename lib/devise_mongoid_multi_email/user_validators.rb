module DeviseMongoidMultiEmail
  module UserValidators
    extend ActiveSupport::Concern

    VALIDATIONS = [
      #:validates_presence_of,
      #:validates_uniqueness_of,
      #:validates_format_of
    ]

    included do
      validates_associated get_devise_email_association
    end

  end
end