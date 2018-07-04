class UsersController < ApplicationController
  before_action :authenticate_user, only: [:update]

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, :status => :ok
    else
      render json: { errors: @user.errors.full_messages}, status: 422
    end
  end

  def update
    if current_user.update(user_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

end
