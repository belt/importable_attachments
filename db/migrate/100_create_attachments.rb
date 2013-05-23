class CreateAttachments < ActiveRecord::Migration

  # Store application specific data for attachments a.k.a. uploaded files
  def change
    create_table :importable_attachments_attachments, :force => true do |t|
      t.string   :attachable_type
      t.string   :attachable_id  # project might be using alpha-numeric IDs
      t.string   :io_stream_file_name
      t.string   :io_stream_content_type
      t.integer  :io_stream_file_size, :limit => 8
      t.datetime :io_stream_updated_at

      t.timestamps
    end
    add_index :importable_attachments_attachments, [:attachable_type, :attachable_id], name: 'idx_importable_attachments_on_attachable_type_and_id'
    add_index :importable_attachments_attachments, :io_stream_file_name
  end
end

