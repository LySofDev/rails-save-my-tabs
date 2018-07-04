require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test "User can be created with valid credentials" do
    new_user = attributes_for(:user)
    refute User.any?, "Some user exists."
    post users_url, params: { user: new_user }
    assert_response :success, "Response was not success."
    assert User.any?, "User was not created."
    json = JSON.parse(response.body)
    assert_equal new_user[:email], json["email"], "Email was not registered."
    assert_includes json.keys, "id", "Id was not included."
    assert_includes json.keys, "created_at", "CreatedAt was not included."
    assert_includes json.keys, "updated_at", "UpdatedAt was not included."
    assert_includes json.keys, "role", "Role was not included."
    refute_includes json.keys, "password", "Password was included."
    refute_includes json.keys, "password_confirmation", "Password Confirmation was included."
    refute_includes json.keys, "password_digest", "Password digest was included."
  end
end
