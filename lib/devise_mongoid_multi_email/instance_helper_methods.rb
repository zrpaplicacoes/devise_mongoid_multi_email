module DeviseMongoidMultiEmail
  module InstanceHelperMethods
    def account_active?
      has_primary_email? && primary_email.confirmed? || confirmed_secondary_emails.any?
    end

    def first_email_record
      result = primary_email
      result ||= valid_emails.first # if no primary email is found
      result
    end

    def confirm_all
      emails.each { |record| record.confirm }
    end

    def email
      primary_email.try(:email) || primary_email.try(:unconfirmed_email) || ""
    end

    def email=(email)
      record = primary_email
      if email
        create_email email, primary: !has_primary_email?
      elsif email.blank? && record
        record.destroy
      end
    end

    def email_changed?
      first_email_record.present? && first_email_record.changed?
    end

    def primary_email
      valid_emails.find(&:primary?)
    end

    def primary_email=(email)
      create_email email, primary: true
    end

    def secondary_emails
      valid_emails.reject { |email| email.primary? }
    end

    def confirmed_secondary_emails
      secondary_emails.reject { |email| !email.confirmed? }
    end

    protected

    def valid_emails
      emails.each.select do |email_record|
        !email_record.destroyed?
      end
    end

    def has_primary_email?
      first_email_record.present? && first_email_record.primary?
    end

    def resource_class
      self.class
    end

    private

    def create_email email, opts
      record = self.class.email_class.new({ unconfirmed_email: email, user: self }.merge(opts))
      self.emails << record
    end

  end
end