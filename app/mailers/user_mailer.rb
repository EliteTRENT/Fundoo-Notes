class UserMailer < ApplicationMailer
  default from: "aryannegi522@gmail.com"

  # def self.enqueue_text_email(user, otp)
  #   channel = RabbitMQ.create_channel
  #   queue = channel.queue("text_emails")

  #   message = { email: user.email, otp: otp }.to_json
  #   queue.publish(message, persistent: true)
  # end

  # def text_mail(email, otp)
  #   @message = "Here is your One Time Password: #{otp}"
  #   Rails.logger.info "Sending mail to #{email}, Please wait..."

  #   # Create an instance of the mailer and send the email
  #   mail(to: email, subject: "Reset Password")
    
  #   Rails.logger.info "Sent Successfully!!"
  # end
  
  def send_otp_email(user, otp)
    @otp = otp
    @user = user
    mail(to: @user.email, subject: 'Your OTP Code')
  end
  
end
