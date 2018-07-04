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

  test "User has_password verifier returns true on matching password" do
    password = "foo-bar-biz"
    user = create(:user, password: password, password_confirmation: password)
    assert user.has_password(password), "User should have matching password."
  end

  test "User has_password verifier returns false on wrong password" do
    password = "foo-bar-biz"
    user = create(:user, password: password, password_confirmation: password)
    refute user.has_password("will-fail"), "User should not have matching password."
  end

end
