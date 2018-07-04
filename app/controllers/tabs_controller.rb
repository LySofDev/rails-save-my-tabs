class TabsController < ApplicationController
  before_action :authenticate_user

  def create
    @tab = current_user.tabs.new(tab_params)
    if @tab.save
      render json: @tab
    else
      render json: { errors: @tab.errors.full_messages }, status: 422
    end
  end

  private

  def tab_params
    params.require(:tab).permit(:url, :title)
  end

end
