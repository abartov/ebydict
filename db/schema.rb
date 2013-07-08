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

ActiveRecord::Schema.define(:version => 20130708043954) do

  create_table "eby_column_images", :force => true do |t|
    t.integer  "eby_scan_image_id"
    t.integer  "colnum"
    t.string   "coljpeg"
    t.string   "coldefjpeg"
    t.string   "colfootjpeg"
    t.integer  "volume"
    t.integer  "pagenum"
    t.string   "status"
    t.integer  "assignedto"
    t.integer  "partitioned_by"
    t.string   "smalljpeg"
    t.integer  "defpartitioner_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "eby_def_events", :force => true do |t|
    t.integer  "who"
    t.integer  "thedef"
    t.string   "old_status"
    t.string   "new_status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "eby_def_part_images", :force => true do |t|
    t.integer  "thedef"
    t.integer  "partnum"
    t.integer  "coldefimg_id"
    t.string   "filename"
    t.integer  "defno"
    t.boolean  "is_last"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "eby_defs", :force => true do |t|
    t.string   "defhead"
    t.text     "deftext"
    t.integer  "assignedto"
    t.string   "status"
    t.integer  "proof_round_passed"
    t.string   "arabic"
    t.string   "greek"
    t.string   "russian"
    t.string   "extra"
    t.text     "footnotes"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "prob_desc"
    t.integer  "reject_count"
    t.integer  "ordinal"
    t.integer  "volume"
  end

  create_table "eby_scan_images", :force => true do |t|
    t.string   "origjpeg"
    t.string   "smalljpeg"
    t.integer  "volume"
    t.integer  "firstpagenum"
    t.integer  "secondpagenum"
    t.string   "status"
    t.integer  "assignedto"
    t.integer  "partitioned_by"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "eby_users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "fullname"
    t.string   "email"
    t.integer  "max_proof_level"
    t.boolean  "role_partitioner"
    t.boolean  "role_typist"
    t.boolean  "role_fixer"
    t.boolean  "role_publisher"
    t.boolean  "role_proofer"
    t.boolean  "does_russian"
    t.boolean  "does_arabic"
    t.boolean  "does_greek"
    t.boolean  "does_extra"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "last_login"
    t.integer  "login_count"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                     :null => false
    t.text     "data",       :limit => 16777215
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sources", :force => true do |t|
    t.string   "title"
    t.string   "nick1"
    t.string   "nick2"
    t.string   "nick3"
    t.integer  "source_algorithm_id"
    t.text     "comments"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

end
