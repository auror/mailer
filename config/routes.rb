Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'users#index'

  resources :users

  get '/login', to: 'users#login'
  post '/login', to: 'users#auth'

  resources :threads, only: [:index, :create, :destroy] do
    member do
      put 'read'
    end
  end

  get '/threads/:type', to: 'threads#get_mails'

  post '/mails/:id/send', to: 'threads#send_draft'
end
