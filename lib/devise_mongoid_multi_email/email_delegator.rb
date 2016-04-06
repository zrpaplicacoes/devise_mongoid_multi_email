module DeviseMongoidMultiEmail
	module EmailDelegator
		extend ActiveSupport::Concern

		included do
			devise :confirmable

			def email_with_indiferent_access
				email || unconfirmed_email
			end

		end

	end
end
