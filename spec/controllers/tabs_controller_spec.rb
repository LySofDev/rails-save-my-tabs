require 'rails_helper'

RSpec.describe TabsController, type: :controller do

  describe "#create" do

    before :each do
      @user = create(:user)
      @tab = build(:tab, user: @user)
      @json_request = {
        data: {
          type: "tabs",
          attributes: {
            title: @tab.title,
            url: @tab.url
          }
        }
      }
    end

    context "without a security token" do

      it "returns a 401 status" do
        post :create, params: @json_request
        expect(response.status).to be 401
      end

      it "doesn't create a new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: @json_request
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
      end

    end

    context "with valid tab data" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 status" do
        post :create, params: @json_request
        expect(response.status).to be 200
      end

      it "creates the new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: @json_request
        expect(Tab.count).to eq 1
        expect(@user.tabs.count).to eq 1
      end

      it "returns the new tab id" do
        post :create, params: @json_request
        expect(json(response)).to eq ({
          data: {
            type: "tabs",
            attributes: {
              id: @user.tabs.last.id,
              title: @user.tabs.last.title,
              url: @user.tabs.last.url,
              userId: @user.tabs.last.user.id
            }
          }
        })
      end

      it "doesn't return errors" do
        post :create, params: @json_request
        expect(json(response).keys).not_to include :errors
      end

    end

    context "with invalid tab data" do

      before :each do
        @json_request[:data][:attributes][:url] = ""
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 422 status" do
        post :create, params: @json_request
        expect(response.status).to be 422
      end

      it "doesn't create a new tab" do
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
        post :create, params: @json_request
        expect(Tab.count).to eq 0
        expect(@user.tabs.count).to eq 0
      end

      it "doesn't return a new tab id" do
        post :create, params: @json_request
        expect(json(response).keys).not_to include :data
      end

      it "returns errors" do
        post :create, params: @json_request
        expect(json(response)).to eq ({
          errors: [
            "Url can't be blank"
          ]
        })
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
        expect(json(response)).to eq ({
          data: {
            count: 20,
            page: {
              offset: 1,
              count: 10
            },
            tabs: @user.tabs.order(created_at: 'DESC').take(10).collect { |tab|
              {
                type: "tabs",
                attributes: {
                  id: tab.id,
                  title: tab.title,
                  url: tab.url,
                  userId: tab.user.id
                }
              }
            }
          }
        })
      end

      it "returns 10 tabs" do
        get :index
        expect(json(response)[:data][:tabs].length).to eq 10
      end

      it "returns the latest tabs" do
        latest_tabs = Tab.order(created_at: "DESC").take(10)
        get :index
        latest_tabs.each_with_index do |tab, i|
          current_tab = json(response)[:data][:tabs][i][:attributes]
          expect(current_tab[:id]).to eq tab.id
          expect(current_tab[:title]).to eq tab.title
          expect(current_tab[:url]).to eq tab.url
        end
      end

      it "returns the total tabs count for the user" do
        other_user = create(:user)
        5.times { create(:tab, user: other_user) }
        expect(Tab.count).to eq 25
        get :index
        expect(json(response)[:data][:count]).to eq 20
      end

      describe "pagination" do

        it "limits the records with the :count query parameter" do
          tab_count = 5
          get :index, params: { count: tab_count }
          expect(json(response)[:data][:page][:count].to_i).to eq tab_count
        end

        it "shifts the records with the :offset query parameter" do
          tab_count = 5
          expected_tabs = Tab.order(created_at: "DESC").offset(5).take(5)
          get :index, params: { offset: 2, count: tab_count}
          expected_tabs.each_with_index do |tab, i|
            current_tab = json(response)[:data][:tabs][i][:attributes]
            expect(current_tab[:id]).to eq tab.id
            expect(current_tab[:title]).to eq tab.title
            expect(current_tab[:url]).to eq tab.url
          end
        end

      end

    end

  end

  describe "#update" do

    before :each do
      @updated_url = "https://www.google.com"
      @user = create(:user)
      @tab = create(:tab, user: @user)
      @json_request = {
        id: @tab.id,
        data: {
          type: "tabs",
          attributes: {
            url: @updated_url
          }
        }
      }
    end

    context "without a security token" do

      it "returns a 401 code" do
        patch :update, params: @json_request
        expect(response.status).to be 401
      end

      it "doesn't update the tab" do
        patch :update, params: @json_request
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq @updated_url
      end

    end

    context "with a different user identity" do

      before :each do
        other_user = create(:user)
        request.headers.merge({ "Authorization" => "Beare #{other_user.as_token}" })
      end

      it "returns a 403 code" do
        patch :update, params: @json_request
        expect(response.status).to be 403
      end

      it "doesn't update the tab" do
        patch :update, params: @json_request
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq @updated_url
      end

    end

    context "with valid update data" do

      before :each do
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 200 code" do
        patch :update, params: @json_request
        expect(response.status).to eq 200
      end

      it "updates the tab" do
        patch :update, params: @json_request
        tab = Tab.find(@tab.id)
        expect(tab.url).to eq @updated_url
      end

      it "returns the updated tab" do
        patch :update, params: @json_request
        expect(json(response)).to eq ({
          data: {
            type: "tabs",
            attributes: {
              id: @tab.id,
              url: @updated_url,
              title: @tab.title,
              userId: @tab.user.id
            }
          }
        })
      end

    end

    context "with invalid update data" do

      before :each do
        @json_request[:data][:attributes][:url] = ""
        request.headers.merge({ "Authorization" => "Beare #{@user.as_token}" })
      end

      it "returns a 422 code" do
        patch :update, params: @json_request
        expect(response.status).to eq 422
      end

      it "doesn't update the tab" do
        patch :update, params: @json_request
        tab = Tab.find(@tab.id)
        expect(tab.url).not_to eq ""
      end

      it "returns error messages" do
        patch :update, params: @json_request
        expect(json(response)).to eq ({
          errors: [
            "Url can't be blank"
          ]
        })
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
        other_user = create(:user)
        request.headers.merge({ "Authorization" => "Beare #{other_user.as_token}" })
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

      it "returns the tab entity" do
        get :show, params: { id: @tab.id }
        expect(json(response)).to eq ({
          data: {
            type: "tabs",
            attributes: {
              id: @tab.id,
              url: @tab.url,
              title: @tab.title,
              userId: @tab.user.id
            }
          }
        })
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
