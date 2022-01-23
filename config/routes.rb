# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'games#index'
  resources :games, only: %i[create destroy show] do
    member do
      post :add_player
      post :add_event
      post :add_event_winner
      post :auto_play
    end
    collection do
      delete :clear_all
    end
  end
end
