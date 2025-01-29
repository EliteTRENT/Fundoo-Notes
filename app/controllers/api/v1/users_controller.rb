class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def createUser
    result = UserService.createUser(user_params)
    if result[:success]
      render json: {message: result[:message]}, status: :created
    else 
      render json: {errors: result[:errors]}, status: :unprocessable_entity
    end
  end

  def login
    result = UserService.login(login_params)
    if result[:success]
      render json: {message: result[:message]}, status: :ok
    else
      render json: {errors: result[:errors]}, status: :unauthorized
    end
  end 

  private 

  def user_params
    params.require(:user).permit(:name, :email, :password, :phone_number)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
