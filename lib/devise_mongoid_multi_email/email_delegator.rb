module DeviseMongoidMultiEmail
	module EmailDelegator
		extend ActiveSupport::Concern

		included do
			devise :confirmable

		end

	end
end
