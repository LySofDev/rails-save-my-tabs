require 'test_helper'

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "should get status" do
    get health_status_url
    assert_response :success
  end

end
