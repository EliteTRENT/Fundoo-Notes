Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
    namespace :api do
      namespace :v1 do
          # APIs for User entity
          post "users" => "users#createUser"
          post "users/login" => "users#login"
          put "users/forgetPassword" => "users#forgetPassword"
          put "users/resetPassword/:id" => "users#resetPassword"

          # APIs for Note entity
          post "notes" => "notes#addNote"
          get "notes/getNote" => "notes#getNote"
          get "notes/getNoteById/:id" => "notes#getNoteById"
          delete "notes/trashToggle/:id" => "notes#trashToggle"
          put "notes/archiveToggle/:id" => "notes#archiveToggle"
          put "notes/changeColor/:id" => "notes#changeColor"
      end
    end
end
