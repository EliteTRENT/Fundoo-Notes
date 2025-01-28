class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def createUser
    user = User.new(user_params)
    if user.save
      render json: {message: "User created successfully"}, status: :created
    else 
      render json: {errors: user.errors.full_messages}, status: :unprocessable_entity
    end
  end
  private 

  def user_params
    params.permit(:name, :email, :password, :phone_number)
  end
end
