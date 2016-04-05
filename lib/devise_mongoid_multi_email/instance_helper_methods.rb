module Devise
  module MongoidMultiEmail

    module InstanceHelperMethods
      def account_active?
        has_primary_email?
      end

      def first_email_record
        valid_emails = emails.each.select do |email_record|
          !email_record.destroyed? && !email_record.marked_for_destruction?
        end

        result = valid_emails.find(&:primary?)
        result ||= valid_emails.first # if no primary email is found
        result
      end

      def confirm_all
        emails.each { |record| record.confirm }
      end

      def email
        first_email_record.try(:email) || first_email_record.try(:unconfirmed_email)
      end

      def email=(email)
        record = first_email_record
        if email
          record ||= emails.build
          record.unconfirmed_email = email
          record.primary = !has_primary_email?
          record.save
        end
      end

      def email_changed?
        first_email_record.present? && first_email_record.changed?
      end

      protected

      def has_primary_email?
        first_email_record.present? &&
        first_email_record.confirmed? &&
        first_email_record.primary?
      end

      def resource_class
        self.class
      end
    end

  end
end