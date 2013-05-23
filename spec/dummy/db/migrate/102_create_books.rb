class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books, force: true do |t|
      t.string :title
      t.string :author
      t.datetime :last_checkout_at
      t.integer :library_id, :null => false
      t.timestamps
    end
  end
end

