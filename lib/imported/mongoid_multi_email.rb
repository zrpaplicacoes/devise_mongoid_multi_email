module Devise
	module MongoidMultiEmail
		extend ActiveSupport::Autoload
		extend ActiveSupport::Concern

		autoload :InstanceHelperMethods
		autoload :InstanceOverrideMethods
		autoload :ClassHelperMethods
		autoload :ClassOverrideMethods
		autoload :EmailDelegator

		included do
			include InstanceHelperMethods
			extend  ClassHelperMethods
			prepend InstanceOverrideMethods

			# Includes Email Delegator module in email_class
			email_class.send :include, EmailDelegator

			# Delegates methods to the first email record available
			delegate :skip_confirmation!,
							 :skip_confirmation_notification!,
							 :skip_reconfirmation!,
							 :confirmation_required?,
							 :confirmation_token,
							 :confirmation_token=,
							 :confirmed_at, :confirmation_sent_at,
							 :confirmation_sent_at=,
							 :confirm, :confirmed?,
							 :unconfirmed_email, :reconfirmation_required?,
							 :pending_reconfirmation?, :email_was,
							 to: :first_email_record, allow_nil: false

			# Overrides Devise Behavior
			# using a Eigenclass to position these
			# methods below the class itself in
			# the ancestors chain and prepends to
			# ensure that the methods defined in the
			# module are way beyond the class definition
			class << self
				prepend ::Devise::MongoidMultiEmail::ClassOverrideMethods
			end
		end

	end
end