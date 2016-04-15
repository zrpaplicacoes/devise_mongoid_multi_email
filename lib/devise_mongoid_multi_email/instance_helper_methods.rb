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

    def emails_list
      emails.order(:primary => :desc).to_a.map { |record| record.email_with_indiferent_access }.join(', ')
    end

    def emails_changed?
      valid_emails.present? && (valid_emails.map { |e| e.changed? || e.new_record? }.any? )
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
      primary_email.present?
    end

    def resource_class
      self.class
    end

    private

    def create_email email, opts
      record = self.class.email_class.new({ unconfirmed_email: email }.merge(opts))
      self.emails << record

      if persisted?
        record.save
      else
        record.save && save
      end

    end

  end
end