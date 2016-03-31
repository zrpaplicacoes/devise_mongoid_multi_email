class User < ApplicationRecord
  ## Relations
  has_many   :emails

  # Includes
  # include Devise::MongoidMultiEmail

  ## Devise
  devise :database_authenticatable,
         :registerable, :recoverable,
         :rememberable, :trackable,
         :confirmable

  # Fields
  ## Database authenticatable
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

end