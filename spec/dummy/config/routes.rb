Rails.application.routes.draw do

  mount ImportableAttachments::Engine => "/importable_attachments"
end
