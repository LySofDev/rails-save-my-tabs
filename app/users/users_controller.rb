class UsersController < ApplicationController
  before_action :authenticate_user, only: [:update, :destroy]

  def create
    operation = Concerns::CreateUser.new(params)
    render json: operation.json, status: operation.status
  end

  def authenticate
    operation = Concerns::AuthenticateUser.new(params)
    render json: operation.json, status: operation.status
  end

  def update
    operation = Concerns::UpdateUser.new(current_user, params)
    render json: operation.json, status: operation.status
  end

  def destroy
    operation = Concerns::DestroyUser.new(current_user)
    render json: operation.json, status: operation.status
  end

end
