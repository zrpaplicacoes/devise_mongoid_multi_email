module Devise
	module MongoidMultiEmail

		module ClassHelperMethods
			def devise_email_association association
				@association = association
			end

			def get_devise_email_association
				@association || :emails
			end

			def reset_devise_email_association
				@association = nil
			end

			def email_class
				association = reflect_on_association(get_devise_email_association)
				association.class_name.demodulize.constantize
			end
		end

	end
end
