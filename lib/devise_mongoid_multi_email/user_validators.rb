module DeviseMongoidMultiEmail
  module UserValidators
    extend ActiveSupport::Concern

    included do
      validates_associated get_devise_email_association

      after_validation :destroy_invalid_emails

      private

      def destroy_invalid_emails
        emails.map do |record|
          unless record.valid?
            write_attribute(:email, "") if record.primary?
            record.delete
          end
        end
      end

    end

  end
end