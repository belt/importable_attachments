Configuration.for('attachments') do
  enabled true
  include_revision_in_filename false
  validate_on_import true
  path ':rails_root/public/system/:rails_env/:style/:attachable_klass/:id_partition/:basename.:extension'
  url %w(development test).include?(Rails.env) ? '/attachments/:id/download' : '/system/:rails_env/:style/:attachable_klass/:id_partition/:basename.:extension'
end

