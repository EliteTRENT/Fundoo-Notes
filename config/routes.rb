Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
          post "users/" => "users#createUser"
          post "users/login" => "users#login"
          put "users/forgetPassword" => "users#forgetPassword"
          put "users/resetPassword/:id" => "users#resetPassword"
      end
    end
end
