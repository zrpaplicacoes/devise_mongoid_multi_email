module Devise
	module MongoidMultiEmail

		module InstanceOverrideMethods
			def active_for_authentication?
				super && account_active?
			end

			def inactive_message
				account_active? ? super : :access_revoked
			end

		  def send_reset_password_instructions params={}
		    token = set_reset_password_token
		    send_devise_notification(:reset_password_instructions, token, { to: params[:email] } )
		    token
		  end

		end

	end
end
