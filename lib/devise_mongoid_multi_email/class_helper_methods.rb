module DeviseMongoidMultiEmail

	module ClassHelperMethods
		def devise_email_association association
			@association = association
		end

		def get_devise_email_association
			@association || email_class_association
		end

		def reset_devise_email_association
			@association = nil
		end

		def email_class
			"#{self.to_s.demodulize}Email".constantize
		end

		def resource_association
			self.to_s.demodulize.underscore.to_sym
		end

		def email_class_association
			:emails
		end

		private

		def retrieve_email_association
			reflect_on_association(get_devise_email_association)
		end

	end

end
