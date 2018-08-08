require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "#create" do

    context "with valid registration data" do

      before :each do
        new_user = build(:user)
        @json_request = {
          data: {
            type: 'users',
            attributes: {
              email: new_user.email,
              password: new_user.password,
              confirmation: new_user.password
            }
          }
        }
      end

      it "will return a 200 status" do
        post :create, params: @json_request
        expect(response.status).to be 200
      end

      it "will create a new user" do
        expect(User.count).to eq 0
        post :create, params: @json_request
        expect(User.count).to eq 1
      end

      it "will return a security token" do
        post :create, params: @json_request
        expect(json(response)).to eq ({
          data: {
            type: 'security_tokens',
            attributes: {
              prefix: 'Bearer',
              token: User.last.as_token
            }
          }
        })
      end

      it "will not return any errors" do
        post :create, params: @json_request
        expect(json(response).keys).not_to include :errors
      end

    end

    context "with invalid registration data" do

      before :each do
        new_user = build(:user)
        @json_request = {
          data: {
            type: 'users',
            attributes: {
              email: new_user.email,
              password: new_user.password,
              confirmation: "will-fail"
            }
          }
        }
      end

      it "will return a 422 status" do
        post :create, params: @json_request
        expect(response.status).to be 422
      end

      it "will not create a new user" do
        expect(User.count).to eq 0
        post :create, params: @json_request
        expect(User.count).to eq 0
      end

      it "will not return a security token" do
        post :create, params: @json_request
        expect(json(response).keys).not_to include :data
      end

      it "will return a list of errors" do
        post :create, params: @json_request
        expect(json(response)).to eq ({
          errors: [
            "Password confirmation doesn't match Password"
          ]
        })
      end

    end

  end

  describe "#authenticate" do

    context "with valid authentication" do

      before :each do
        @user = build(:user)
        @json_request = {
          data: {
            type: 'user_credentials',
            attributes: {
              email: @user.email,
              password: @user.password
            }
          }
        }
        @user.save!
      end

      it "will return a 200 status" do
        post :authenticate, params: @json_request
        expect(response.status).to be 200
      end

      it "will return a security token" do
        post :authenticate, params: @json_request
        expect(json(response)).to eq({
          data: {
            type: 'security_tokens',
            attributes: {
              prefix: "Bearer",
              token: @user.as_token
            }
          }
        })
      end

      it "will not return error messages" do
        post :authenticate, params: @json_request
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "errors"
      end

    end

    context "with invalid authentication" do

      before :each do
        @user = build(:user)
        @json_request = {
          data: {
            type: 'user_credentials',
            attributes: {
              email: @user.email,
              password: "will-fail"
            }
          }
        }
        @user.save!
      end

      it "will return a 422 status" do
        post :authenticate, params: @json_request
        expect(response.status).to be 422
      end

      it "will not return a security token" do
        post :authenticate, params: @json_request
        expect(json(response).keys).not_to include :data
      end

      it "will return error messages" do
        post :authenticate, params: @json_request
        expect(json(response)).to eq ({
          errors: [
            "Invalid email or password."
          ]
        })
      end

    end

  end

  describe "#update" do

    before :each do
      @new_email = "foo.bar@gmail.com"
      @user = create(:user)
      @json_request = {
        data: {
          type: "users",
          attributes: {
            email: @new_email
          }
        }
      }
    end

    context "without a security token" do

      it "returns a 401 status" do
        patch :update, params: @json_request
        expect(response.status).to eq 401
      end

      it "doesn't update the user" do
        patch :update, params: @json_request
        user = User.find(@user.id)
        expect(user.email).not_to eq @new_user
      end

    end

    context "with a security token" do

      before :each do
        request.headers.merge({ 'Authorization' => "Bearer #{@user.as_token}" })
      end

      it "returns a 200 status" do
        patch :update, params: @json_request
        expect(response.status).to eq 200
      end

      it "updates the user" do
        patch :update, params: @json_request
        user = User.find(@user.id)
        expect(user.email).to eq @new_email
      end

    end

  end

  describe "#destroy" do

    before :each do
      @user = create(:user)
    end

    context "without a security token" do

      it "returns a 401 status" do
        delete :destroy
        expect(response.status).to be 401
      end

      it "doesn't destroy the user" do
        delete :destroy
        user = User.find(@user.id)
        expect(user).to be_persisted
      end

    end

    context "with a security token" do

      before :each do
        request.headers.merge({ 'Authorization' => "Bearer #{@user.as_token}" })
      end

      it "returns a 200 status" do
        delete :destroy
        expect(response.status).to be 200
      end

      it "destroys the user record" do
        delete :destroy
        matching_users = User.where(id: @user.id).count
        expect(matching_users).to eq 0
      end
    end

  end

end
