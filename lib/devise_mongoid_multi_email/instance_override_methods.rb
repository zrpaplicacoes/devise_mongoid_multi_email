module DeviseMongoidMultiEmail
	module InstanceOverrideMethods
		def active_for_authentication?
			account_active? && super
		end

		def inactive_message
			account_active? ? super : :access_revoked
		end

	  def send_reset_password_instructions params={}
	    token = set_reset_password_token
	    send_devise_notification(:reset_password_instructions, token, { to: params[:email] } )
	    token
	  end

    def confirmed?
      return false unless emails.any?
      primary_email ? primary_email.confirmed? : false
    end

	end
end