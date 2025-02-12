class UserService
  def self.createUser(user_params)
    user = User.new(user_params)
    if user.save
      { success: true, message: "User created successfully" }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end

  def self.login(login_params)
    user = User.find_by(email: login_params[:email])
    raise StandardError, "Invalid email" if user.nil?
    raise StandardError, "Invalid password" unless user.authenticate(login_params[:password])
    if user && user.authenticate(login_params[:password])
      token = JsonWebToken.encode(id: user.id, name: user.name, email: user.email)
      { success: true, message: "Login successful", token: token }
    else
      { success: false, errors: "Invalid email or password" }
    end
  end

  def self.forgetPassword(fp_params)
    user = User.find_by(email: fp_params[:email])
    if user
      @@otp = rand(100000..999999)
      @@otp_generated_at = Time.current
      # UserMailer.text_mail(user.email,@@otp).deliver_now
      send_otp_to_queue(user.email, @@otp)
      Thread.new { OtpWorker.start }
      # UserMailer.enqueue_text_email(user,@@otp)
      { success: true, message: "OTP has been sent to #{user.email}, check your inbox" }
    else
      { success: false }
    end
  end

  def self.send_otp_to_queue(email, otp)
    connection = Bunny.new
    connection.start
    channel = connection.create_channel
    queue = channel.queue("otp_queue", durable: true)

    message = { email: email, otp: otp }.to_json
    queue.publish(message, persistent: true)

    connection.close
  end

  def self.resetPassword(user_id, rp_params)
    if rp_params[:otp].to_i == @@otp && (Time.current - @@otp_generated_at < 1.minute)
      user = User.find_by(id: user_id)
      if user
        user.update(password: rp_params[:new_password])
        @@otp = nil
        { success: true }
      else
        { success: false, errors: "User not found" }
      end
    else
      { success: false, errors: "Invalid OTP" }
    end
  end

  private
  @@otp = nil
  @@otp_generated_at = nil
end
