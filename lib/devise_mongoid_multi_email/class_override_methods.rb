module DeviseMongoidMultiEmail
	module ClassOverrideMethods
		def find_first_by_auth_conditions(tainted_conditions, opts={})
		  conditions =  tainted_conditions.dup
		  if email = conditions.delete(:email)
		    email = /^#{Regexp.escape(email)}$/i
		    unscoped do
			    email_class.unscoped.where(opts).or({ email: email }, { unconfirmed_email: email } ).first.try(:user)
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
		  recoverable = find_or_initialize_with_errors_for_reset(reset_password_keys, attributes, :not_found_or_unconfirmed)
		  byebug
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

		private

		def is_confirmed_association_record? confirmable_record
			confirmable_record.present? && (confirmable_record.respond_to? :confirmed?) && confirmable_record.confirmed?
		end

	end

end
