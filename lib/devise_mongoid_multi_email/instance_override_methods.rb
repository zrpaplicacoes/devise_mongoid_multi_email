module DeviseMongoidMultiEmail
	module InstanceOverrideMethods
		def active_for_authentication?
			account_active? && super
		end

		def inactive_message
			account_active? ? super : :access_revoked
		end

	  def send_reset_password_instructions params={}
	  	if confirmed? && emails.where(email: params[:email]).first.confirmed?
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

	end
end
