class UserService
  def self.createUser(user_params)
    user = User.new(user_params)
    if user.save
      return {success: true, message: "User created successfully"}
    else 
      return {success: false, errors: user.errors.full_messages}
    end
  end

  def self.login(login_params)
    user = User.find_by(email: login_params[:email])
    raise StandardError, "Invalid email" if user.nil?
    raise StandardError, "Invalid password" unless user.authenticate(login_params[:password])
    if user && user.authenticate(login_params[:password])
      token = JsonWebToken.encode(id: user.id, name: user.name, email: user.email)
      return {success: true, message: "Login successful", token: token}
    else 
      return {success: false, errors: "Invalid email or password"}
    end    
  end
  
  def self.forgetPassword(fp_params)
    user = User.find_by(email: fp_params[:email])
    if user
      @@otp = rand(100000..999999)
      return {success: true, otp: @@otp}
    else
      return {success: false}
    end
  end

  def self.resetPassword(user_id,rp_params)
    if rp_params[:otp].to_i == @@otp
      user = User.find_by(id: user_id)
      if user 
        user.update(password: rp_params[:new_password])
        @@otp = nil
        return {success: true}
      else 
        return {success: false, errors: "User not found"}
      end
    else
      return {success: false, errors: "Invalid OTP"}
    end
  end

  private 
  @@otp = nil
end
