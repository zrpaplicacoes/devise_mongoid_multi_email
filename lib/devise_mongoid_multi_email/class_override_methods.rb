module DeviseMongoidMultiEmail
	module ClassOverrideMethods

		def find_first_by_auth_conditions(tainted_conditions, optional_conditions={})
		  conditions =  tainted_conditions.dup
		  if email = conditions.delete(:email)
		  	find_first_by_email(email, conditions)
		  elsif reset_password_token = conditions.delete(:reset_password_token)
		    find_first_by_recover_conditions(reset_password_token, conditions)
		  elsif confirmation_token = conditions.delete(:confirmation_token)
				find_first_by_confirmation_conditions(confirmation_token, conditions)
			else
		    unscoped.where(conditions.merge(optional_conditions)).first
		  end
		end

		def find_first_by_email(email, optional_conditions={})
	    email = /^#{Regexp.escape(email)}$/i
	    unscoped do
		    email_class.unscoped.where(optional_conditions).or({ email: email }, { unconfirmed_email: email } ).first.try(:user)
		  end
		end

		def find_first_by_recover_conditions(reset_password_token, optional_conditions={})
			token = /^#{Regexp.escape(reset_password_token)}$/i
	    unscoped.where(optional_conditions).where(reset_password_token: token).first
		end

		def find_first_by_confirmation_conditions(confirmation_token, optional_conditions={})
			token = /^#{Regexp.escape(confirmation_token)}$/i
	    unscoped do
	    	email_class.unscoped.where(optional_conditions).where(confirmation_token: token).first.try(:user)
			end
		end

		def send_reset_password_instructions(attributes={})
		  recoverable = find_or_initialize_with_errors_for_reset(reset_password_keys, attributes, :not_found_or_unconfirmed)
		  recoverable.send_reset_password_instructions(attributes) if recoverable.persisted?
		  recoverable
		end

		def find_or_initialize_with_errors_for_reset(required_attributes, attributes, error=:not_found_or_unconfirmed, &block)
			if required_attributes.include? :email
				confirmable_record ||= email_class.unscoped.where(email: attributes[:email]).first
			else
				confirmable_record ||= block.call
			end

			record = find_or_initialize_with_errors(required_attributes, attributes, error)

			if record && record.confirmed? && is_confirmed_association_record?(confirmable_record)
				record
			else
				record = new
				required_attributes.each do |key|
					value = attributes[key]
					record.send("#{key}=", value)
					record.errors.add(key, value.present? ? error : :blank)
				end
				record
			end

		end

		def send_confirmation_instructions resource_params
			email_class.send_confirmation_instructions(resource_params)
		end

		def confirm_by_token confirmation_token
			confirmable = find_first_by_auth_conditions(confirmation_token: confirmation_token)
			if confirmable
				email = confirmable.emails.where(confirmation_token: confirmation_token).first
				email.confirm if email.persisted?
			else
				confirmation_digested = Devise.token_generator.digest(self, :confirmation_token, confirmation_token)
				confirmable = email_class.find_or_initialize_with_error_by(:confirmation_token, confirmation_digested)
			end

			confirmable
		end

		private

		def is_confirmed_association_record? confirmable_record
			confirmable_record.present? && (confirmable_record.respond_to? :confirmed?) && confirmable_record.confirmed?
		end

	end

end
