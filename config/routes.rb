ImportableAttachments::Engine.routes.draw do
  root to: 'attachments#index'
  resources :versions
  resources :attachments
  match 'attachments/:id/download', action: :download, via: :get
end

Rails.application.routes.draw do
  resources :attachments, controller: 'importable_attachments/attachments'
  match 'attachments/:id/download', controller: 'importable_attachments/attachments', action: :download, via: :get
end
