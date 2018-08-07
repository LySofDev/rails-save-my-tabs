require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe "GET" do
    describe "/status" do
      it "returns a 200 response" do
        get :status
        assert_response :success
      end
    end
  end
end
