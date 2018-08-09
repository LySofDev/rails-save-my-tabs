class TabsController < ApplicationController
  before_action :authenticate_user
  before_action :find_tab_with_current_user, only: [:show, :update, :destroy]

  def index
    operation = Concerns::IndexTabs.new(current_user, params)
    render json: operation.json, status: operation.status
  end

  def show
    render json: @tab
  end

  def create
    operation = Concerns::CreateTab.new(current_user, params)
    render json: operation.json, status: operation.status
  end

  def update
    operation = Concerns::UpdateTab.new(current_user, params)
    render json: operation.json, status: operation.status
  end

  def destroy
    @tab.destroy
    render json: nil, status: 200
  end

  private

  def tab_params
    params.require(:tab).permit(:url, :title)
  end

  def find_tab_with_current_user
    begin
      @tab = current_user.tabs.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: nil, status: 403
      return false
    end
  end

  def page_count
    params[:count] || 10
  end

  def page_offset
    params[:offset] || 1
  end

end
