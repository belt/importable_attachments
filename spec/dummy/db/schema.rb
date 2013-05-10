# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 100) do

  create_table "attachments", :force => true do |t|
    t.string   "attachable_type"
    t.string   "attachable_id"
    t.string   "io_stream_file_name"
    t.string   "io_stream_content_type"
    t.integer  "io_stream_file_size", :limit => 8
    t.datetime "io_stream_updated_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type", :null => false
    t.string   "item_id", :null => false
    t.string   "event", :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  create_table 'libraries', :force => true do |t|
    t.string 'name'
    t.string 'address'
    t.datetime 'created_at', :null => false
    t.datetime 'updated_at', :null => false
  end

  create_table 'books', :force => true do |t|
    t.string 'title'
    t.string 'author'
    t.datetime 'last_checkout_at'
    t.integer 'library_id', :null => false
    t.datetime 'created_at', :null => false
    t.datetime 'updated_at', :null => false
  end

end
