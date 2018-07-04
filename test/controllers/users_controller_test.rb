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

  test "User can't be created with invalid credentials" do
    new_user = attributes_for(:user, password: "will-fail")
    refute_equal new_user[:password], new_user[:password_confirmation], "Invalid model passed validations."
    refute User.any?, "Some user exists."
    post users_url, params: { user: new_user }
    assert_response 422
    refute User.any?, "Invalid user was created."
    json = JSON.parse(response.body)
    assert_equal({ "errors" => ["Password confirmation doesn't match Password"] }, json)
  end

  test "User can be updated with authorization" do
    user = create(:user)
    new_email = "mac.hdz@gmail"
    updated_attributes = { email: new_email }
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    authenticated_header = { 'Authorization': "Bearer #{token}" }
    patch user_url(user), params: { user: updated_attributes}, headers: authenticated_header
    assert_response :success, "Response was not success."
    json = JSON.parse(response.body)
    assert_equal new_email, json["email"], "Email was not updated."
  end

  test "User cannot be updasted without authorization" do
    user = create(:user)
    new_email = "mac.hdz@gmail"
    updated_attributes = { email: new_email }
    patch user_url(user), params: { user: updated_attributes}
    assert_response 401, "Response should have been 401 - Unauthorized."
  end

  test "User cannot update with invalid data" do
    user = create(:user)
    new_email = ""
    updated_attributes = { email: new_email }
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    authenticated_header = { 'Authorization': "Bearer #{token}" }
    patch user_url(user), params: { user: updated_attributes}, headers: authenticated_header
    assert_response 422, "Response should be 422 - Unprocessable Entity."
    json = JSON.parse(response.body)
    assert_equal ["Email can't be blank"], json["errors"]
  end
end
