class User < ApplicationRecord

  # Encrypted password stored in database as password_digest
  has_secure_password

  # User has client role by default
  enum role: [:client, :admin]

  # Email cannot be empty and must be unique
  validates :email,
    presence: true,
    uniqueness: true

  # Hide :password_digest from serialized object
  def as_json(options = {})
    super(options.merge({ except: [:password_digest] }))
  end

end
