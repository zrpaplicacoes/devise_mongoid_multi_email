module DeviseMongoidMultiEmail
	module InstanceOverrideMethods

		def active_for_authentication?
			account_active? && super
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

    def emails()
    	super
    end

    def emails=(emails)
    	byebug
    end

	end
end
