class UsersController < ApplicationController
  before_action :authenticate_user, only: [:update, :destroy]

  def create
    @user = build_user_from_params
    if @user.save
      render json: { payload: @user.as_token, prefix: "Bearer" }
    else
      render json: { errors: @user.errors.full_messages }, status: 422
    end
  end

  def authenticate
    @user = User.find_by_email(authenticate_params["email"])
    if @user and @user.has_password(authenticate_params["password"])
      render json: { payload: @user.as_token, prefix: "Bearer" }
    else
      render json: { errors: ["Invalid email or password"] }, status: 422
    end
  end

  def update
    if current_user.update(update_user_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: 422
    end
  end

  def destroy
    current_user.destroy
    render json: { success: true }, status: 200
  end

  private

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :passwordConfirmation)
  end

  def update_user_params
    params.require(:user).permit(:email, :password)
  end

  def authenticate_params
    params.require(:authenticate).permit(:email, :password)
  end

  def build_user_from_params
    User.new do |u|
      u.email = params[:email]
      u.password = params[:password]
      u.password_confirmation = params[:passwordConfirmation] || params[:password_confirmation]
    end
  end

end
