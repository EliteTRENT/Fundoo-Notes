Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        #APIs for User entity
          post "users" => "users#createUser"
          post "users/login" => "users#login"
          put "users/forgetPassword" => "users#forgetPassword"
          put "users/resetPassword/:id" => "users#resetPassword"

        #APIs for Note entity
          post "notes" => "notes#addNote"
      end
    end
end
