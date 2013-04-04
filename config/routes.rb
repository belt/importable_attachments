ImportableAttachments::Engine.routes.draw do
  root to: 'versions#index'
  resources :versions
end
