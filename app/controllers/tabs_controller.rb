class TabsController < ApplicationController
  before_action :authenticate_user
  before_action :find_tab_with_current_user, only: [:show, :update, :destroy]

  def index
    @tab_count = current_user.tabs.count
    @tabs = current_user.tabs
      .order(:created_at => :desc)
      .page(page_offset).per(page_count)
    render json: {
      tabs: @tabs,
      count: @tab_count,
      page: {
        offset: page_offset,
        count: page_count
      }
    }
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

  def page_count
    params[:count] || 10
  end

  def page_offset
    params[:offset] || 1
  end

end
