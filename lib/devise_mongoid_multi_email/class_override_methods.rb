module Devise
	module MongoidMultiEmail

		module ClassOverrideMethods
			def find_first_by_auth_conditions(tainted_conditions, opts={})
			  conditions =  tainted_conditions.dup
			  if email = conditions.delete(:email)
			    email = /^#{Regexp.escape(email)}$/i
			    unscoped do
				    email_class.unscoped.where(opts).or({ email: email }).first.try(:user)
				  end
			  else
			    find_first_by_recover_conditions(conditions)
			  end
			end

			def find_first_by_recover_conditions(conditions, optional_conditions={})
			  if token = conditions.delete(:reset_password_token)
			  	token = /^#{Regexp.escape(token)}$/i
			    unscoped.where(optional_conditions).where(reset_password_token: token).first
			  else
			    unscoped.where(optional_conditions.merge(conditions || {})).first
			  end
			end

			def send_reset_password_instructions(attributes={})
			  recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found_or_unconfirmed)
			  recoverable.send_reset_password_instructions(attributes) if recoverable.persisted?
			  recoverable
			end
		end

	end
end
