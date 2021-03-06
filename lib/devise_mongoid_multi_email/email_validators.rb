module DeviseMongoidMultiEmail
  module EmailValidators
    extend ActiveSupport::Concern
    VALIDATIONS = [
      :validates_presence_of,
      :validates_uniqueness_of,
      :validates_format_of
    ]

    included do

      # Uniqueness Validations
      validates_uniqueness_of :email, allow_blank: true, if: :email_changed?

      validates_uniqueness_of :primary, scope: ["#{resource_relation.to_s}_id".to_sym], if: 'primary?'

      # Presence Validations
      validates_presence_of :primary
      validates_presence_of :email, unless: 'unconfirmed_email.present?'
      validates_presence_of :unconfirmed_email, unless: 'email.present?'

      # Format Validations
      validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
      validates_format_of :unconfirmed_email, with: Devise.email_regexp, allow_blank: true, if: :unconfirmed_email_changed?

      # Custom Validations
      validate :email_or_unconfirmed_email_present?
      validate :has_identical_email_confirmed?
      validate :identical_email_for_the_same_resource?

      # After callbacks
      after_validation :propagates_errors_to_email_attribute
      after_validation :propagates_errors_to_email_attribute_of_resource
      after_validation :delete_identical_emails_if_confirmed

      private

      def email_error_messages
        (errors['email'] | errors['unconfirmed_email']).uniq
      end

      def email_or_unconfirmed_email_present?
        errors.add(:email, :blank) if email_with_indiferent_access.blank?
      end

      def has_identical_email_confirmed?
        errors.add(:email, :taken) if duplicated_emails_except_self.present?
      end

      def identical_email_for_the_same_resource?
        if resource
          if duplicated_unconfirmed_emails_except_self.present?
            errors.add(:email, :taken)
            raise Mongoid::Errors::Validations, self
          end
        else
          errors.add(resource_relation, :blank)
        end
      end

      def propagates_errors_to_email_attribute
        messages = email_error_messages

        errors['email'].clear
        errors['unconfirmed_email'].clear


        messages.each do |message|
          errors.add(:email, message)
        end

      end

      def propagates_errors_to_email_attribute_of_resource
        messages = email_error_messages
        messages.each do |message|
          resource.errors.add(:email, message) if resource
        end
      end

      def delete_identical_emails_if_confirmed
        if confirmed?
          self.class.not_in(:_id => [self.id]).where(:unconfirmed_email => email_with_indiferent_access).delete_all
        end
      end

      def duplicated_unconfirmed_emails_except_self
        resource.emails.where(unconfirmed_email: email_with_indiferent_access).to_a.reject { |record| record == self }
      end

      def duplicated_emails_except_self
        self.class.not_in(:_id => [self.id]).where(email: email_with_indiferent_access).to_a
      end


    end

  end
end
