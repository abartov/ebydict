# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_29_073335) do

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "eby_aliases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "eby_def_id", null: false
    t.string "alias"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["eby_def_id"], name: "index_eby_aliases_on_eby_def_id"
  end

  create_table "eby_column_images", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.integer "eby_scan_image_id"
    t.integer "colnum"
    t.string "coljpeg"
    t.string "coldefjpeg"
    t.string "colfootjpeg"
    t.integer "volume"
    t.integer "pagenum"
    t.string "status"
    t.integer "assignedto"
    t.integer "partitioned_by"
    t.string "smalljpeg"
    t.integer "defpartitioner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "eby_def_events", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.integer "who"
    t.integer "thedef"
    t.string "old_status"
    t.string "new_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thedef", "new_status"], name: "index_eby_def_events_on_thedef_and_new_status"
  end

  create_table "eby_def_part_images", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.integer "thedef"
    t.integer "partnum"
    t.integer "coldefimg_id"
    t.string "filename"
    t.integer "defno"
    t.boolean "is_last"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thedef"], name: "index_eby_def_part_images_on_thedef"
  end

  create_table "eby_defs", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.string "defhead"
    t.text "deftext", size: :medium
    t.integer "assignedto"
    t.string "status"
    t.integer "proof_round_passed"
    t.string "arabic"
    t.string "greek"
    t.string "russian"
    t.string "extra"
    t.text "footnotes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prob_desc"
    t.integer "reject_count"
    t.integer "ordinal"
    t.integer "volume"
    t.integer "proof_round_passed_negative"
    t.boolean "aliases_done"
    t.index ["aliases_done"], name: "index_eby_defs_on_aliases_done"
    t.index ["assignedto"], name: "index_eby_defs_on_assignedto"
    t.index ["defhead"], name: "index_eby_defs_on_defhead"
    t.index ["id", "assignedto"], name: "index_eby_defs_on_id_and_assignedto"
    t.index ["proof_round_passed"], name: "index_eby_defs_on_proof_round_passed"
    t.index ["reject_count", "proof_round_passed"], name: "index_eby_defs_on_reject_count_and_proof_round_passed"
    t.index ["status"], name: "index_eby_defs_on_status"
  end

  create_table "eby_markers", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "def_id"
    t.integer "partnum"
    t.integer "marker_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "eby_scan_images", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.string "origjpeg"
    t.string "smalljpeg"
    t.integer "volume"
    t.integer "firstpagenum"
    t.integer "secondpagenum"
    t.string "status"
    t.integer "assignedto"
    t.integer "partitioned_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "eby_users", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.string "login"
    t.string "password"
    t.string "fullname"
    t.string "email"
    t.integer "max_proof_level"
    t.boolean "role_partitioner"
    t.boolean "role_typist"
    t.boolean "role_fixer"
    t.boolean "role_publisher"
    t.boolean "role_proofer"
    t.boolean "does_russian"
    t.boolean "does_arabic"
    t.boolean "does_greek"
    t.boolean "does_extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login"
    t.integer "login_count"
    t.string "google_token"
    t.string "google_refresh_token"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", collation: "utf8_bin", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data", size: :medium
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "eby_aliases", "eby_defs"
end
