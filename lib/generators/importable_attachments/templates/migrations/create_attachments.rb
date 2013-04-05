class CreateAttachments < ActiveRecord::Migration

  # Store application specific data for attachments a.k.a. uploaded files
  def change
    create_table :attachments, :force => true do |t|
      t.string :attachable_type
      t.integer :attachable_id, :limit => 8
      t.string :io_stream_file_name
      t.string :io_stream_content_type
      t.integer :io_stream_file_size, :limit => 8
      t.datetime :io_stream_updated_at

      t.timestamps
    end
    add_index :attachments, [:attachable_type, :attachable_id]
    add_index :attachments, :io_stream_file_name
  end
end

