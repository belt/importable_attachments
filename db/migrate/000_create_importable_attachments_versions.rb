class CreateImportableAttachmentsVersions < ActiveRecord::Migration
  def change
    create_table :importable_attachments_versions, force: true do |t|
      t.string :item_type, null: false
      t.string :item_id, null: false  # item_type.id generally should be GUID
      t.string :event, null: false
      t.string :whodunnit
      t.text :object
      t.datetime :created_at
    end
    add_index :importable_attachments_versions, [:item_type, :item_id]
  end
end

