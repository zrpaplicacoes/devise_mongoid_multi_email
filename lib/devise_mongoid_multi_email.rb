require "devise_mongoid_multi_email/engine"

module DeviseMongoidMultiEmail
	extend ActiveSupport::Concern

	autoload :InstanceHelperMethods    , 'devise_mongoid_multi_email/instance_helper_methods'
	autoload :InstanceOverrideMethods  , 'devise_mongoid_multi_email/instance_override_methods'
	autoload :ClassHelperMethods       , 'devise_mongoid_multi_email/class_helper_methods'
	autoload :ClassOverrideMethods     , 'devise_mongoid_multi_email/class_override_methods'
	autoload :EmailDelegator           , 'devise_mongoid_multi_email/email_delegator'
	autoload :UserValidators           , 'devise_mongoid_multi_email/user_validators'
	autoload :EmailValidators          , 'devise_mongoid_multi_email/email_validators'

	included do
		prepend InstanceOverrideMethods
		include InstanceHelperMethods
		extend  ClassHelperMethods
		include UserValidators

		has_many :emails, dependent: :delete, autosave: true, class_name: "#{self.to_s.demodulize}Email" do
			def << (records)
				result = super(records)
				Array(records).each { |record| record.send_confirmation_instructions if (record.valid? && record.persisted? && !record.primary?) }

				result.reject { |record| !record.persisted? }
			end
		end

		# Includes Email Delegator module in email_class
		email_class.send :include, EmailDelegator
		email_class.send :belongs_to, resource_association

		# Field used to store email information
	  field :email, type: String, default: ""

		# Delegates methods to the primary email record
		delegate :skip_confirmation!,
						 :skip_confirmation_notification!,
						 :skip_reconfirmation!,
						 :confirmation_required?,
						 :confirmation_token,
						 :confirmation_token=,
						 :confirmed_at, :confirmation_sent_at,
						 :confirmation_sent_at=,
						 :confirm, :unconfirmed_email,
						 :unconfirmed_email,
						 :unconfirmed_email=,
						 to: :primary_email

		# Overrides Devise Behavior using a Eigenclass to position these
		# methods below the class itself in the ancestors chain and
		# prepends to ensure that the methods defined in the module are
		# way beyond the class definition
		class << self
			prepend ::DeviseMongoidMultiEmail::ClassOverrideMethods
		end

	end
end

