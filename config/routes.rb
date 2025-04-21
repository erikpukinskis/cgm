Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # Docs
  mount OasRails::Engine => "/docs"

  # Auth
  get "auth/join", to: "auth#join_form"
  post "auth/join", to: "auth#join"
  get "auth/sign_in", to: "auth#sign_in_form"
  post "auth/sign_in", to: "auth#sign_in"
  get "auth/sign_out", to: "auth#sign_out"

  scope "api" do
    scope "v1" do
      get "metrics/glucose_summary", to: "metrics#glucose_summary"
    end
  end
end
