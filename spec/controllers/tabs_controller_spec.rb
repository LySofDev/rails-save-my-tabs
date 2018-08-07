require 'rails_helper'

RSpec.describe TabsController, type: :controller do

  describe "#create" do

    context "without a security token" do

      before :each do
        @user = create(:user)
        @tab_data = attributes_for(:tab, user: @user)
      end

      it "returns a 401 status" do
        post :create, params: { tab: @tab_data }
        expect(response.status).to be 401
      end

      it "doesn't create a new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: { tab: @tab_data }
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
      end

    end

    context "with valid tab data" do

      before :each do
        @user = create(:user)
        @tab_data = attributes_for(:tab, user: @user)
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 status" do
        post :create, params: { tab: @tab_data }
        expect(response.status).to be 200
      end

      it "creates the new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: { tab: @tab_data }
        expect(Tab.count).to eq 1
        expect(@user.tabs.count).to eq 1
      end

      it "returns the new tab id" do
        post :create, params: { tab: @tab_data }
        json = JSON.parse(response.body)
        expect(json.keys).to include "id"
        expect(json["id"]).to eq Tab.last.id
      end

      it "doesn't return errors" do
        post :create, params: { tab: @tab_data }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "errors"
      end

    end

    context "with invalid tab data" do

      before :each do
        @user = create(:user)
        @tab_data = attributes_for(:tab, user: @user, url: "")
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 422 status" do
        post :create, params: { tab: @tab_data }
        expect(response.status).to be 422
      end

      it "doesn't create a new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: { tab: @tab_data }
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
      end

      it "doesn't return a new tab id" do
        post :create, params: { tab: @tab_data }
        json = JSON.parse(response.body)
        expect(json.keys).not_to include "id"
      end

      it "returns errors" do
        post :create, params: { tab: @tab_data }
        json = JSON.parse(response.body)
        expect(json.keys).to include "errors"
        expect(json["errors"]).to include "Url can't be blank"
      end

    end

  end

  describe "#index" do

    before :each do
      @user = create(:user)
      20.times { create(:tab, user: @user )}
    end

    context "without a security token" do

      it "returns a 401 status" do
        get :index
        expect(response.status).to eq 401
      end

    end

    context "with a security token" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 status" do
        get :index
        expect(response.status).to eq 200
      end

      it "returns tabs belonging to the user" do
        get :index
        json = JSON.parse(response.body)
        expect(json.keys).to include "tabs"
        json["tabs"].each do |tab|
          expect(tab["user_id"]).to eq @user.id
        end
      end

      it "returns 10 tabs" do
        get :index
        json = JSON.parse(response.body)
        expect(json["tabs"].count).to eq 10
      end

      it "returns the latest tabs" do
        latest_tabs = Tab.order(created_at: "DESC").take(10)
        get :index
        json = JSON.parse(response.body)
        latest_tabs.each_with_index do |tab, i|
          current_tab = json["tabs"][i]
          expect(current_tab["id"]).to eq tab.id
          expect(current_tab["title"]).to eq tab.title
          expect(current_tab["url"]).to eq tab.url
        end
      end

      describe "pagination" do

        it "limits the records with the :count query parameter" do
          tab_count = 5
          get :index, params: { count: tab_count }
          json = JSON.parse(response.body)
          expect(json["tabs"].count).to eq tab_count
        end

        it "shifts the records with the :offset query parameter" do
          tab_count = 5
          expected_tabs = Tab.order(created_at: "DESC").offset(5).take(5)
          get :index, params: { offset: 2, count: tab_count}
          json = JSON.parse(response.body)
          expected_tabs.each_with_index do |tab, i|
            current_tab = json["tabs"][i]
            expect(current_tab["id"]).to eq tab.id
            expect(current_tab["title"]).to eq tab.title
            expect(current_tab["url"]).to eq tab.url
          end
        end

      end

    end

  end

  describe "#update" do

    before :each do
      @user = create(:user)
      @tab = create(:tab, user: @user)
      @tab_data = { url: "https://www.google.com" }
    end

    context "without a security token" do

      it "returns a 401 code" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        expect(response.status).to be 401
      end

      it "doesn't update the tab" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq @tab_data[:url]
      end

    end

    context "with a different user identity" do

      before :each do
        user = create(:user)
        request.headers.merge({ "Authorization" => "Beare #{user.as_token}" })
      end

      it "returns a 403 code" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        expect(response.status).to be 403
      end

      it "doesn't update the tab" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq @tab_data[:url]
      end

    end

    context "with valid update data" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 code" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        expect(response.status).to eq 200
      end

      it "updates the tab" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        tab = Tab.find(@tab.id)
        expect(tab.url).to eq @tab_data[:url]
      end

    end

    context "with invalid update data" do

      before :each do
        @tab_data[:url] = ""
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 422 code" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        expect(response.status).to eq 422
      end

      it "doesn't update the tab" do
        patch :update, params: { id: @tab.id, tab: @tab_data }
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq ""
      end

    end

  end

  describe "#show" do

    before :each do
      @user = create(:user)
      @tab = create(:tab, user: @user)
    end

    context "without a security token" do
      it "returns a 401 code" do
        get :show, params: { id: @tab.id }
        expect(response.status).to eq 401
      end
    end

    context "with a different user identity" do

      before :each do
        user = create(:user)
        request.headers.merge({ "Authorization" => "Beare #{user.as_token}" })
      end

      it "returns a 403 code" do
        get :show, params: { id: @tab.id }
        expect(response.status).to eq 403
      end

    end

    context "with a matching user identity" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 code" do
        get :show, params: { id: @tab.id }
        expect(response.status).to eq 200
      end

      it "returns the tab url" do
        get :show, params: { id: @tab.id }
        json = JSON.parse(response.body)
        expect(json["url"]).to eq @tab.url
      end

      it "returns the tab title" do
        get :show, params: { id: @tab.id }
        json = JSON.parse(response.body)
        expect(json["title"]).to eq @tab.title
      end

    end

  end

  describe "#destroy" do

    before :each do
      @user = create(:user)
      @tab = create(:tab, user: @user)
    end

    context "without a security token" do
      it "returns a 401 code" do
        delete :destroy, params: { id: @tab.id }
        expect(response.status).to eq 401
      end
    end

    context "with an incorrect user identity" do

      before :each do
        user = create(:user)
        request.headers.merge({ "Authorization" => "Beare #{user.as_token}" })
      end

      it "returns a 403 code" do
        delete :destroy, params: { id: @tab.id }
        expect(response.status).to eq 403
      end
    end

    context "with a correct user identity" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 code" do
        delete :destroy, params: { id: @tab.id }
        expect(response.status).to eq 200
      end

      it "destroys the tab record" do
        delete :destroy, params: { id: @tab.id }
        matching_tabs = Tab.where(id: @tab.id).count
        expect(matching_tabs).to eq 0
      end

    end
    
  end

end
