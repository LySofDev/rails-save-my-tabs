require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "#create" do

    context "with valid registration data" do

      before :each do
        @user_data = attributes_for(:user)
      end

      it "will return a 200 status" do
        post :create, params: { user: @user_data }
        expect(response.status).to be 200
      end

      it "will create a new user" do
        expect(User.count).to eq 0
        post :create, params: { user: @user_data }
        expect(User.count).to eq 1
      end

      it "will return a security token" do
        post :create, params: { user: @user_data }
        json = JSON.parse(response.body)
        expect(json.keys).to include "prefix"
        expect(json.keys).to include "payload"
        expect(json["prefix"]).to eq "Bearer"
        expect(json["payload"]).to eq User.last.as_token
      end

      it "will not return any errors" do
        post :create, params: { user: @user_data }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "errors"
      end

    end

    context "with invalid registration data" do

      before :each do
        @user_data = attributes_for(:user, password: "will-fail")
      end

      it "will return a 422 status" do
        post :create, params: { user: @user_data }
        expect(response.status).to be 422
      end

      it "will not create a new user" do
        expect(User.count).to eq 0
        post :create, params: { user: @user_data }
        expect(User.count).to eq 0
      end

      it "will not return a security token" do
        post :create, params: { user: @user_data }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "prefix"
        expect(json.keys).not_to include "payload"
      end

      it "will return a list of errors" do
        post :create, params: { user: @user_data }
        json = JSON.parse(response.body)
        expect(json.keys).to include "errors"
        expect(json["errors"]).to include "Password confirmation doesn't match Password"
      end

    end

  end

  describe "#authenticate" do

    context "with valid authentication" do

      before :each do
        @user = build(:user)
        @credentials = {
          email: @user.email,
          password: @user.password
        }
        @user.save!
      end

      it "will return a 200 status" do
        post :authenticate, params: { authenticate: @credentials }
        expect(response.status).to be 200
      end

      it "will return a security token" do
        post :authenticate, params: { authenticate: @credentials }
        json = JSON.parse(response.body)
        expect(json.keys).to include "payload"
        expect(json.keys).to include "prefix"
        expect(json["payload"]).to eq @user.as_token
        expect(json["prefix"]).to eq "Bearer"
      end

      it "will not return error messages" do
        post :authenticate, params: { authenticate: @credentials }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "errors"
      end

    end

    context "with invalid authentication" do

      before :each do
        @user = build(:user)
        @credentials = {
          email: @user.email,
          password: "will-fail"
        }
        @user.save!
      end

      it "will return a 422 status" do
        post :authenticate, params: { authenticate: @credentials }
        expect(response.status).to be 422
      end

      it "will not return a security token" do
        post :authenticate, params: { authenticate: @credentials }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "prefix"
        expect(json.keys).not_to include "payload"
        expect(json.values).not_to include @user.as_token
      end

      it "will return error messages" do
        post :authenticate, params: { authenticate: @credentials }
        json = JSON.parse(response.body)
        expect(json.keys).to include "errors"
        expect(json["errors"]).to include "Invalid email or password"
      end

    end

  end

end
