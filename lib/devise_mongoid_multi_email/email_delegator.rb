module Devise
	module MongoidMultiEmail

		module EmailDelegator
			extend ActiveSupport::Concern

			included do
				devise :confirmable

			end

		end

	end
end
