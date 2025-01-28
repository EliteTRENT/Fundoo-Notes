Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
          post "users/" => "users#createUser"
          # post "users/login" => "users#login"
      end
    end
end
