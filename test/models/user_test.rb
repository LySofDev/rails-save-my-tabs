require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "User with matching passwords is valid" do
    user = build(:user)
    user.password = "password"
    user.password_confirmation = "password"
    assert user.valid?, "Matching passwords are not valid."
  end

  test "User without matching passwords is invalid" do
    user = build(:user)
    user.password = "password"
    user.password_confirmation = "invalid"
    assert user.invalid?, "Non-matching passwords are valid."
  end

  test "User with empty passwords is invalid" do
    user = build(:user)
    user.password = ""
    user.password_confirmation = ""
    assert user.invalid?, "Empty passwords are valid."
  end

  test "User with empty email is invalid" do
    user = build(:user)
    user.email = ""
    assert user.invalid?, "Empty email is valid."
  end

  test "User has client role by default" do
    user = build(:user)
    assert user.client?, "Default role is not client."
  end

  test "User email must be unique" do
    first_user = create(:user)
    second_user = build(:user, email: first_user.email)
    assert second_user.invalid?, "Email should be unique."
  end
end
