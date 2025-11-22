Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
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
        resources :assignments
        resources :assignment_grade_links
      end

      namespace :course do
        resources :courses
        resources :course_schedules
        resources :course_schedule_links
        resources :course_schedule_overrides
      end

      namespace :users do
        resources :grades
        resources :roles
        resources :users
        resources :user_role_links
      end

      resources :test_table
  end
end
