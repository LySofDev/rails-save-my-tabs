class Tab < ApplicationRecord

  # All tabs are owned by a user
  belongs_to :user

  # Url is a required value
  validates :url,
    presence: true
    
end
