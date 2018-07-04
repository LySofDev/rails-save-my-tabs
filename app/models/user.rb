class User < ApplicationRecord

  # Encrypted password stored in database as password_digest
  has_secure_password

  # User has client role by default
  enum role: [:client, :admin]

  # Email cannot be empty
  validates_presence_of :email
  
end
