class Email < ApplicationRecord
	belongs_to :user

	# Basic Email Setup
	field :email   , type: String
	field :primary , type: Boolean

	# Confirmable fields
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :confirmation_token,   type: String
  field :unconfirmed_email,    type: String
end