module DeviseMongoidMultiEmail
	module EmailDelegator
		extend ActiveSupport::Concern

		included do
			devise :confirmable

			class << self
				prepend ::DeviseMongoidMultiEmail::EmailDelegator::ClassOverrideMethods
			end

			def resource
				self.send(resource_relation)
			end

			def resource_class_name
				self.class.to_s.demodulize.gsub("Email", "")
			end

			def email_with_indiferent_access
				email || unconfirmed_email
			end

			def update_email_and_send_reconfirmation_instructions email
				self.email = nil
				self.unconfirmed_email = email
				self.confirmation_token = nil
				self.confirmed_at = nil
				if save
					send_confirmation_instructions
				else
					false
				end
			end

			def send_confirmation_instructions
				unless @raw_confirmation_token
					generate_confirmation_token!
				end

				opts = { to: email_with_indiferent_access }
        send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
        @raw_confirmation_token
			end

			def send_devise_notification(notification, *args)
				unless new_record? || changed?
					devise_mailer.send(notification, self.send(resource_relation), *args).deliver
				end
			end

			extend ::DeviseMongoidMultiEmail::EmailDelegator::Helpers
			include ::DeviseMongoidMultiEmail::EmailDelegator::Helpers
			include ::DeviseMongoidMultiEmail::EmailValidators

		end

		module Helpers
			def resource_class
				resource_class_name.constantize
			end

			def resource_relation
				resource_class_name.underscore.to_sym
			end
		end

		module ClassOverrideMethods
			def resource_class_name
				self.to_s.demodulize.gsub("Email", "")
			end


			def send_confirmation_instructions(attributes={})
	      confirmable = self.where(unconfirmed_email: attributes[:to] || attributes[:email]).first

	      return find_or_initialize_with_error_by(:unconfirmed_email, attributes[:to] || attributes[:email], :not_found) unless confirmable

	      confirmable.send_confirmation_instructions if confirmable.persisted?

	      confirmable
	    end

		end

	end



end
