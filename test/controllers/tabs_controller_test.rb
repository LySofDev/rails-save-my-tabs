require 'test_helper'

class TabsControllerTest < ActionDispatch::IntegrationTest

  test "An authenticated user can create a tab" do
    user = create(:user)
    refute Tab.any?, "No tabs should exist."
    new_tab = attributes_for(:tab, user: user)
    authorized_headers = { 'Authorization': "Bearer #{user.as_token}" }
    post tabs_url, params: { tab: new_tab }, headers: authorized_headers
    assert_response :success, "Response should be successful"
    assert Tab.any?, "Tab should have been created."
    json = JSON.parse(response.body)
    assert_equal new_tab[:title], json["title"], "Title was not persisted."
    assert_equal new_tab[:url], json["url"], "Url was not persisted."
  end

  test "An unauthenticated cannot create a tab" do
    user = create(:user)
    refute Tab.any?, "No tabs should exist."
    new_tab = attributes_for(:tab, user: user)
    post tabs_url, params: { tab: new_tab }
    assert_response 401, "Response should be 401 - Unauthorized"
    refute Tab.any?, "No tabs should be created."
  end

  test "Invalid tabs cannot be created" do
    user = create(:user)
    refute Tab.any?, "No tabs should exist."
    new_tab = attributes_for(:tab, user: user, url: nil)
    authorized_headers = { 'Authorization': "Bearer #{user.as_token}" }
    post tabs_url, params: { tab: new_tab }, headers: authorized_headers
    assert_response 422, "Response should be 422 - Unprocesable Entity"
    refute Tab.any?, "Tab should not be created."
    json = JSON.parse(response.body)
    assert_equal ["Url can't be blank"], json["errors"], "Error was not received."
  end

  test "Tab can be updated by authorized user" do
    user = create(:user)
    authorized_headers = { 'Authorization': "Bearer #{user.as_token}" }
    tab = create(:tab, user: user)
    updated_tab = { title: "The New Title" }
    patch tab_url(tab), params: { tab: updated_tab }, headers: authorized_headers
    assert_response :success, "Response should be successful"
    json = JSON.parse(response.body)
    assert_equal updated_tab[:title], json["title"], "Title was not persisted."
  end

  test "Tab cannot be updated by unauthoized user" do
    user = create(:user)
    tab = create(:tab, user: user)
    updated_tab = { title: "The New Title" }
    patch tab_url(tab), params: { tab: updated_tab }
    assert_response 401, "Response should be 401 - Unauthorized"
  end

  test "Tab cannot be updated by another user" do
    user = create(:user)
    other_user = create(:user)
    authorized_headers = { 'Authorization': "Bearer #{other_user.as_token}" }
    tab = create(:tab, user: user)
    updated_tab = { title: "The New Title" }
    patch tab_url(tab), params: { tab: updated_tab }, headers: authorized_headers
    assert_response 403, "Response should be 403 - Forbidden"
  end

  test "Tab cannot be updated with invalid data" do
    user = create(:user)
    authorized_headers = { 'Authorization': "Bearer #{user.as_token}" }
    tab = create(:tab, user: user)
    updated_tab = { url: nil }
    patch tab_url(tab), params: { tab: updated_tab }, headers: authorized_headers
    assert_response 422, "Response should 422 - Unprocesable"
    json = JSON.parse(response.body)
    assert_equal ["Url can't be blank"], json["errors"], "Errors were not passed."
  end

  test "Tab can be destroyed by authorized owner" do
    user = create(:user)
    authorized_headers = { 'Authorization': "Bearer #{user.as_token}" }
    tab = create(:tab, user: user)
    assert Tab.any?, "A tab should exist."
    delete tab_url(tab), headers: authorized_headers
    assert_response :success, "Response should be successful"
    refute Tab.any?, "A tab should be destroyed."
  end

  test "Tab cannot be destroyed by another authorized user" do
    user = create(:user)
    other_user = create(:user)
    authorized_headers = { 'Authorization': "Bearer #{other_user.as_token}" }
    tab = create(:tab, user: user)
    assert Tab.any?, "A tab should exist."
    delete tab_url(tab), headers: authorized_headers
    assert_response 403, "Response should be 403 - Forbidden"
    assert Tab.any?, "A tab should not be destroyed."
  end

  test "Tab cannot be destroyed by unauthoized user" do
    user = create(:user)
    tab = create(:tab, user: user)
    assert Tab.any?, "A tab should exist."
    delete tab_url(tab)
    assert_response 401, "Response should be 401 - Unauthorized"
    assert Tab.any?, "A tab should not be destroyed."
  end

end
