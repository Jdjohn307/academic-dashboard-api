Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
      namespace :assignment do
      resources :assignment
      resources :assignment_grade_link
      end

      namespace :course do
      resources :course
      resources :course_schedule
      resources :course_schedule_link
      resources :course_schedule_override
      end

      namespace :users do
      resources :grade
      resources :role
      resources :user
      resources :user_role_link
      end

      resources :test_table
  end
end
