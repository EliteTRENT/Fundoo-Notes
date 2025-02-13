require 'rails_helper'

RSpec.describe UserService, type: :service do
  describe "#createUser" do
    context "when the user is created successfully" do
      it "returns a success message" do
        user_params = { name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241" }
        
        result = UserService.createUser(user_params)

        expect(result[:success]).to be(true)
        expect(result[:message]).to eq("User created successfully")
      end
    end

    context "when the user creation fails" do
      it "returns an error message when name is missing" do
        user_params = { name: nil, email: "john@example.com", password: "Password123@", phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Name can't be blank")
      end

      it "returns an error message when email is missing" do
        user_params = { name: "John Doe", email: nil, password: "Password123@", phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Email can't be blank")
      end
  
      it "returns an error message when password is missing" do
        user_params = { name: "John Doe", email: "john@example.com", password: nil, phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Password can't be blank")
      end
  
      it "returns an error message when phone number is missing" do
        user_params = { name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: nil }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Phone number can't be blank")
      end
  
      it "returns an error message when email format is invalid" do
        user_params = { name: "John Doe", email: "invalidemail", password: "Password123@", phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Email Must be a valid email")
      end
  
      it "returns an error message when phone number format is invalid" do
        user_params = { name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "12345" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Phone number Must be a valid phone number")
      end

      it "returns an error message when password format is invalid" do
        user_params = { name: "John Doe", email: "john@example.com", password: "Passwor", phone_number: "7087777805" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Password Must be a valid password")
      end
  
      it "returns an error message when email is not unique" do
        User.create!(name: "Jane Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        user_params = { name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Email has already been taken")
      end
  
      it "returns an error message when phone number is not unique" do
        User.create!(name: "Jane Doe", email: "jane@example.com", password: "Password123@", phone_number: "+8907653241")
        user_params = { name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241" }
  
        result = UserService.createUser(user_params)
  
        expect(result[:success]).to be(false)
        expect(result[:errors]).to include("Phone number has already been taken")
      end
    end
  end

  describe "#login" do
    context "when the login is successful" do
      it "returns a success message with a token" do
        User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        login_params = { email: "john@example.com", password: "Password123@" }

        result = UserService.login(login_params)

        expect(result[:success]).to be(true)
        expect(result[:message]).to eq("Login successful")
        expect(result[:token]).to be_present
      end
    end

    context "when the email is invalid" do
      it "raises an invalid email error" do
        User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        login_params = { email: "john123@example.com", password: "Password123@" }

        expect { UserService.login(login_params) }.to raise_error(StandardError, "Invalid email")
      end
    end

    context "when the password is incorrect" do
      it "raises an invalid password error" do
        User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        login_params = { email: "john@example.com", password: "WrongPassword@" }

        expect { UserService.login(login_params) }.to raise_error(StandardError, "Invalid password")
      end
    end
  end

  describe "#forgetPassword" do
    context "when the email exists" do
      it "sends an OTP to the email" do
        User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        fp_params = { email: "john@example.com" }

        result = UserService.forgetPassword(fp_params)

        expect(result[:success]).to be(true)
        expect(result[:message]).to eq("OTP has been sent to john@example.com, check your inbox")
        expect(result[:otp]).to be_present
        expect(result[:otp_generated_at]).to be_present
      end
    end

    context "when the email does not exist" do
      it "returns failure" do
        fp_params = { email: "nonexistent@example.com" }

        result = UserService.forgetPassword(fp_params)

        expect(result[:success]).to be(false)
      end
    end
  end

  describe "#resetPassword" do
    context "when OTP is valid" do
      it "resets the user's password" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        fp_params = { email: "john@example.com" }
        result_forget = UserService.forgetPassword(fp_params)
        
        # Ensure OTP and time are properly passed
        expect(result_forget[:otp]).to be_present
        expect(result_forget[:otp_generated_at]).to be_present
      
        rp_params = { otp: result_forget[:otp], otp_generated_at: result_forget[:otp_generated_at], new_password: "NewPassword123@" }
      
        result = UserService.resetPassword(user.id, rp_params)
      
        expect(result[:success]).to be(true)
        user.reload
        expect(user.authenticate("NewPassword123@")).to be_truthy
      end
    end

    context "when OTP is invalid" do
      it "returns failure" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        rp_params = { otp: "wrongotp", new_password: "NewPassword123@" }

        result = UserService.resetPassword(user.id, rp_params)

        expect(result[:success]).to be(false)
        expect(result[:errors]).to eq("Invalid OTP")
      end
    end

    context "when OTP expires" do
      it "returns failure" do
        user = User.create!(name: "John Doe", email: "john@example.com", password: "Password123@", phone_number: "+8907653241")
        
        # Simulating OTP expiration
        rp_params = { otp: "expiredotp", new_password: "NewPassword123@" }

        result = UserService.resetPassword(user.id, rp_params)

        expect(result[:success]).to be(false)
        expect(result[:errors]).to eq("Invalid OTP")
      end
    end
  end
end
