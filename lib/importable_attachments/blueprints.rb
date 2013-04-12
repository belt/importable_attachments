require 'machinist/active_record'

ImportableAttachments::Attachment.blueprint do
  io_stream { File.new Rails.root.join('spec', 'attachments', 'mostly_empty_copy.xls') }
end

Version.blueprint do
end

