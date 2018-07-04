require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  test "User can be created with valid credentials" do
    new_user = attributes_for(:user)
    refute User.any?, "Some user exists."
    post users_url, params: { user: new_user }
    assert_response :success, "Response was not success."
    assert User.any?, "User was not created."
    token = Knock::AuthToken.new(payload: { sub: User.last.id }).token
    json = JSON.parse(response.body)
    assert_equal({ "token" => token }, json, "Token should have been returned.")
    refute_includes json.keys, "email", "Email should not be included."
    refute_includes json.keys, "id", "Id should not be included."
    refute_includes json.keys, "created_at", "CreatedAt should not be included."
    refute_includes json.keys, "updated_at", "UpdatedAt should not be included."
    refute_includes json.keys, "role", "Role should not be included."
    refute_includes json.keys, "password", "Password should not be included."
    refute_includes json.keys, "password_confirmation", "Password Confirmation should not be included."
    refute_includes json.keys, "password_digest", "Password digest should not be included."
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

  test "Authorized user can destroy account" do
    user = create(:user)
    assert User.any?, "A user should exist."
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    authenticated_header = { 'Authorization': "Bearer #{token}" }
    delete user_url(user), headers: authenticated_header
    assert_response :success, "Response should be success."
    refute User.any?, "No users should exist."
  end

  test "Unauthorized user cannot destroy account" do
    user = create(:user)
    assert User.any?, "A user should exist."
    delete user_url(user)
    assert_response 401, "Response should be 401 - Unauthorized"
    assert User.any?, "A user should not be deleted."
  end

  test "User can autheticate with valid email and password" do
    user = create(:user)
    credentials = { email: user.email, password: "password" }
    post authenticate_user_url, params: { authenticate: credentials }
    assert_response :success, "Response should be successful"
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    json = JSON.parse(response.body)
    assert_equal({ "token" => token }, json, "Token should have been returned.")
  end

  test "User cannot authenticate with invalid email and password" do
    user = create(:user)
    credentials = { email: user.email, password: "will-fail" }
    post authenticate_user_url, params: { authenticate: credentials }
    assert_response 422, "Response should be 422 - Unprocessable"
    json = JSON.parse(response.body)
    assert_equal({ "errors" => ["Invalid email or password"] }, json, "Error message should be included.")
  end

  test "User cannot authenticate if email isn't registered" do
    user = build(:user)
    credentials = { email: user.email, password: "password" }
    post authenticate_user_url, params: { authenticate: credentials }
    assert_response 422, "Response should be 422 - Unprocessable"
    json = JSON.parse(response.body)
    assert_equal({ "errors" => ["Invalid email or password"] }, json, "Error message should be included.")
  end
end
