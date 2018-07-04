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

  end

  test "Invalid tabs cannot be created" do

  end

end
