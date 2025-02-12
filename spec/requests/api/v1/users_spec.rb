require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/users' do
    post 'Register a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      # ✅ Ensure user is wrapped correctly in request body
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {   # ✅ Add this wrapper to match Postman's working request
            type: :object,
            properties: {
              name: { type: :string },
              email: { type: :string },
              password: { type: :string },
              phone_number: { type: :string, example: "+919876543210" }  # ✅ Added mobile_number
            },
            required: [ 'name', 'email', 'password', 'phone_number' ]
          }
        }
      }

      response '201', 'User registered successfully' do
        let(:user) { { name: 'John Doe', email: 'john@example.com', password: 'Password@123', phone_number: '+919876543210' } }
        run_test!
      end

      response '422', 'Invalid request' do
        let(:user) { { email: 'invalid-email' } }
        run_test!
      end
    end
  end


  path '/api/v1/users/login' do
    post 'Login a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {  # ✅ Wrap in user
            type: :object,
            properties: {
              email: { type: :string, example: "agrimchaudhary2@gmail.com" },
              password: { type: :string, example: "Agrim@2021" }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '200', 'Login successful' do
        let(:user) { { user: { email: 'agrimchaudhary2@gmail.com', password: 'Agrim@2021' } } }  # ✅ Now correctly wrapped
        run_test!
      end

      response '400', 'Invalid password' do
        let(:user) { { user: { email: 'agrimchaudhary2@gmail.com', password: 'wrongpassword' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users/forgetPassword' do
    put 'Forget Password' do
      tags 'Users'
      consumes 'application/json'
      # No token required
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {  # Ensures Swagger request format matches Postman
            type: :object,
            properties: {
              email: { type: :string, example: "kanojiavishal0401@gmail.com" }
            },
            required: [ 'email' ]
          }
        }
      }

      response '200', 'OTP has been sent to the provided email' do
        let(:user) { { user: { email: 'kanojiavishal0401@gmail.com' } } }
        run_test!
      end

      response '404', 'User not found' do
        let(:user) { { user: { email: 'nonexistent@example.com' } } }
        run_test!
      end
    end
  end



  path '/api/v1/users/resetPassword/{id}' do
    put 'Reset Password' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, description: 'User ID'
      parameter name: :reset_data, in: :body, schema: {
        type: :object,
        properties: {
          otp: { type: :string },
          new_password: { type: :string }
        },
        required: [ 'otp', 'new_password' ]
      }
  
      response '200', 'Password reset successfully' do
        let(:id) { '123' } # Example user ID
        let(:reset_data) { { otp: '123456', new_password: 'newpassword123' } }
        run_test!
      end
  
      response '400', 'Invalid OTP' do
        let(:id) { '123' } # Example user ID
        let(:reset_data) { { otp: '000000', new_password: 'newpassword123' } }
        run_test!
      end
  
      response '404', 'User not found' do
        let(:id) { 'non_existent_id' } # Example for a user not found scenario
        let(:reset_data) { { otp: '123456', new_password: 'newpassword123' } }
        run_test!
      end
    end
  end
end
