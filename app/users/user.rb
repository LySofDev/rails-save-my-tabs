class User < ApplicationRecord

  # Encrypted password stored in database as password_digest
  has_secure_password

  # All tabs belong to a user
  has_many :tabs

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

  # Verify that a password matches
  def has_password(password)
    BCrypt::Password.new(self.password_digest) == password
  end

  # The user as a principal for Token
  def as_principal
    { id: self.id, email: self.email, role: self.role }
  end

  # Return the User as a JWT token
  def as_token
    Knock::AuthToken.new(payload: { sub: self.as_principal }).token
  end

  # Find the current user from the payload's subject.id
  def self.from_token_payload(payload)
    self.find(payload["sub"]["id"])
  end
end
