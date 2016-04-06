module DeviseMongoidMultiEmail
	module EmailDelegator
		extend ActiveSupport::Concern

		included do
			devise :confirmable

			def email_with_indiferent_access
				email || unconfirmed_email
			end

			def send_confirmation_instructions
				unless @raw_confirmation_token
					generate_confirmation_token!
				end

				opts = { to: unconfirmed_email }
        self.class.send_confirmation_instructions(opts)
			end

			class << self
				prepend ::DeviseMongoidMultiEmail::EmailDelegator::ClassOverrideMethods
			end

		end

		module ClassOverrideMethods
			def send_confirmation_instructions(attributes={})
	      confirmable = find_by_unconfirmed_email_with_errors(attributes) if reconfirmable
	      unless confirmable.try(:persisted?)
	        confirmable = find_or_initialize_with_errors(confirmation_keys, attributes, :not_found)
	      end
	      confirmable.resend_confirmation_instructions if confirmable.persisted?
	      confirmable
	    end
		end

	end
end
