class TabsController < ApplicationController
  before_action :authenticate_user
  before_action :find_tab_with_current_user, only: [:show, :update, :destroy]

  def index
    render json: current_user.tabs
  end

  def show
    render json: @tab
  end

  def create
    @tab = current_user.tabs.new(tab_params)
    if @tab.save
      render json: @tab
    else
      render json: { errors: @tab.errors.full_messages }, status: 422
    end
  end

  def update
    if @tab.update(tab_params)
      render json: @tab
    else
      render json: { errors: @tab.errors.full_messages }, status: 422
    end
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

end
