class User < ApplicationRecord

  include DeviseMongoidMultiEmail

  # Dummy Field
  field :name, type: String

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :confirmable, :validatable

  ## Database authenticatable
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

end