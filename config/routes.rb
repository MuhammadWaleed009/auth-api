Rails.application.routes.draw do
  post "/signup", to: "users#signup"
  get "/users/:id", to: "users#show"
  patch "/users/:id", to: "users#update"
  post "/close", to: "users#close"
end
