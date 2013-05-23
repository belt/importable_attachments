class CreateLibraries < ActiveRecord::Migration
  def change
    create_table :libraries, force: true do |t|
      t.string :name
      t.string :address
      t.timestamps
    end
  end
end

