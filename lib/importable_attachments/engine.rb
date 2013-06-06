require 'configuration'
require 'rails/alpha_numeric_validator'

module ImportableAttachments
  # integrate importable_attachments machina into rails
  class Engine < ::Rails::Engine
    isolate_namespace ImportableAttachments
  end
end
