# An attachment represents a file within the system.
class Attachment < ImportableAttachments::Attachment
end

# == Schema Information
#
# Table name: attachments
#
#  id                     :integer          not null, primary key
#  attachable_type        :string(255)
#  attachable_id          :string(255)
#  io_stream_file_name    :string(255)
#  io_stream_content_type :string(255)
#  io_stream_file_size    :integer
#  io_stream_updated_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  idx_importable_attachments_on_attachable_type_and_id  (attachable_type,attachable_id)
#  index_attachments_on_io_stream_file_name              (io_stream_file_name)
#

