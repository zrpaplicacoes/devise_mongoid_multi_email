module DeviseMongoidMultiEmail
  module InstanceOverrideMethods

    def active_for_authentication?
      account_active? && confirmed? && super
    end

    def inactive_message
      account_active? ? super : :access_revoked
    end

    def send_reset_password_instructions params={}
      email = emails.where(email: params[:email]).first
      if confirmed? && email && email.confirmed?
        token = set_reset_password_token
        send_devise_notification(:reset_password_instructions, token, { to: params[:email] } )
        token
      else
        false
      end
    end

  def confirmed?
    return false unless emails.any?
    primary_email.present? ? primary_email.confirmed? : false
  end

  def email
    primary_email.try(:email) || primary_email.try(:unconfirmed_email) || read_attribute(:email)
  end

  def email=(email)
    record = primary_email

    if email && record.blank?
      write_attribute(:email, email)
      valid?
      build_email email, primary: true unless errors.keys.include? :email
    elsif email && record && record.valid?
      record.update_email_and_send_reconfirmation_instructions(email)
    elsif email.blank? && record
      write_attribute(:email, nil)
      record.delete
      self.reload
    end
  end

  def emails=(emails)
    emails = emails.gsub(" ", '').split(',')

    email_instances = emails.map do |email|
      new_email = self.class.email_class.new(unconfirmed_email: email, primary: false, self.class.resource_association => self)

      unless new_email.valid?
        self.reload
        raise Mongoid::Errors::Validations, new_email
      end

      new_email
    end

    self.emails << email_instances
  end

  def pending_reconfirmation?
    emails.present? && emails.map(&:pending_reconfirmation?).any?
  end

  def unconfirmed_email
    if has_primary_email?
      primary_email.unconfirmed_email
    else
      ""
    end

  end

  def unconfirmed_email=(email)
    if has_primary_email?
      primary_email.update(unconfirmed_email: email)
    else
      ""
    end

  end

  end
end
