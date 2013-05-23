Paperclip.interpolates :stream_version do |attachment, _|
  attachment.instance.revision_number
end

Paperclip.interpolates :attachable_klass do |attachment, _|
  attachable_type = attachment.instance.attachable_type
  attachable_type && attachable_type.respond_to?(:tableize) ? attachable_type.tableize : '.'
end

Paperclip.interpolates :rails_env do |_, _|
  Rails.env
end

# brew on darwin
if File.directory?(File.join("", 'usr', 'local', 'bin'))
  Paperclip.options[:command_path] = '/usr/local/bin'

# macports on darwin
elsif File.directory?(File.join("", 'opt', 'local', 'bin'))
  Paperclip.options[:command_path] = '/opt/local/bin'

# "disabled" macports due to brew on darwin
elsif File.directory?(File.join("", 'opt', 'local.brew', 'bin'))
  Paperclip.options[:command_path] = '/opt/local.brew/bin'
else
  raise RuntimeError, 'can not locate identify binary'
end
