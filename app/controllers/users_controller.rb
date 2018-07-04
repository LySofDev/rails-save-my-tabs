class UsersController < ApplicationController
  before_action :authenticate_user, only: [:update, :destroy]

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { token: @user.as_token }
    else
      render json: { errors: @user.errors.full_messages }, status: 422
    end
  end

  def authenticate
    @user = User.find_by_email(authenticate_params["email"])
    if @user and @user.has_password(authenticate_params["password"])
      render json: { token: @user.as_token }
    else
      render json: { errors: ["Invalid email or password"] }, status: 422
    end
  end

  def update
    if current_user.update(user_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: 422
    end
  end

  def destroy
    current_user.destroy
    render json: nil, status: 200
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def authenticate_params
    params.require(:authenticate).permit(:email, :password)
  end

end
