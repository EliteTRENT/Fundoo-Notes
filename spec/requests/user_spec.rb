require 'rails_helper'

RSpec.describe "User Authentication", type: :request do
  describe "POST /api/v1/users" do
    it "registers a new user successfully" do
      post "/api/v1/users", params: {
        user: {
          name: "Test User",
          email: "test@example.com",
          phone_number: "8884567890",
          password: "Strong@123"
        }
      }, as: :json
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq("User created successfully")
    end

    it "fails to register with invalid email" do
      post "/api/v1/users", params: {
        user: {
          name: "Test User",
          email: "invalid-email",
          phone_number: "8884567890",
          password: "Strong@123"
        }
      }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).not_to be_empty
    end
  end

  describe "POST /api/v1/users/login" do
    before do
      User.create!(name: "Test User", email: "test@example.com", phone_number: "8884567890", password: "Strong@123")
    end

    context "with valid credentials" do
      it "logs in and returns a token" do
        post "/api/v1/users/login", params: { user: { email: "test@example.com", password: "Strong@123" } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Login successful")
        expect(JSON.parse(response.body)["token"]).not_to be_nil
      end
    end

    context "with invalid email" do
      it "returns an error message" do
        post "/api/v1/users/login", params: { user: { email: "invalid@example.com", password: "Strong@123" } }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["errors"]).to eq("Invalid email")
      end
    end

    context "with invalid password" do
      it "returns an error message" do
        post "/api/v1/users/login", params: { user: { email: "test@example.com", password: "WrongPassword" } }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["errors"]).to eq("Invalid password")
      end
    end

    context "with missing parameters" do
      it "returns an error when email is missing" do
        post "/api/v1/users/login", params: { user: { password: "Strong@123" } }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["errors"]).to eq("Invalid email")
      end

      it "returns an error when password is missing" do
        post "/api/v1/users/login", params: { user: { email: "test@example.com" } }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["errors"]).to eq("Invalid password")
      end
    end
  end
end
