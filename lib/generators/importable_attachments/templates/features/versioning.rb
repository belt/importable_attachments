Configuration.for('versioning') do
  enabled true
  validate_item_type_constants false
  path ':rails_root/public/system/:rails_env/:style/:attachable_klass/:id_partition/:basename.:stream_version.:extension'
  url %w(development test).include?(Rails.env) ? '/attachments/:id/download' : '/system/:rails_env/:style/:attachable_klass/:id_partition/:basename.:stream_version.:extension'
end

