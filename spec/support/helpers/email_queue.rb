module RSpec
	module Support

		module EmailQueue

			def reset_deliveries
				ActionMailer::Base.deliveries = []
			end

			def deliveries_size
				deliveries.size
			end

			def deliveries
				ActionMailer::Base.deliveries
			end

		end

	end
end