class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/, message: "Must be a valid email" }
  validates :password, presence: true, format: {with: /\A(?=[A-Za-z0-9@#$%^]*[A-Z])(?=[A-Za-z0-9@#$%^]*[a-z])(?=[A-Za-z0-9@#$%^]*\d)(?=[A-Za-z0-9@#$%^]*[@#$%^])[A-Za-z0-9@#$%^]{8,}\z/, message: "Must be a valid password"} 
  validates :phone_number, presence: true, uniqueness: true, format: { with: /\A[+]?[6-9]\d{9,14}\z/, message: "Must be a valid phone number" }
end
