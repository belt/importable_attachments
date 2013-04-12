require 'configuration'
require 'rails/alpha_numeric_validator'

module ImportableAttachments
  class Engine < ::Rails::Engine
    isolate_namespace ImportableAttachments
  end
end
