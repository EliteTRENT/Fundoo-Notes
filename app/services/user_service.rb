class UserService
  def initialize(user_params,login_params)
    @user_params = user_params
    @login_params = login_params
  end

  def createUser
    user = User.new(@user_params)
    if user.save
      return {success: true, message: "User created successfully"}
    else 
      return {success: false, errors: user.errors.full_messages}
    end
  end

  def login
    user = User.find_by(email: @login_params[:email])
    if user && user.authenticate(@login_params[:password])
      token = JsonWebToken.encode(id: user.id, name: user.name, email: user.email)
      return {success: true, message: "Login successful", token: token}
    else 
      return {success: false, errors: "Invalid email or password"}
    end    
  end
end
