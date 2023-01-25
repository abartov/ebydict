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

ActiveRecord::Schema.define(version: 2023_01_25_222514) do

  create_table "active_storage_attachments", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false, collation: "utf8mb4_unicode_ci"
    t.string "record_type", null: false, collation: "utf8mb4_unicode_ci"
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "latin1", force: :cascade do |t|
    t.string "key", null: false, collation: "utf8mb4_unicode_ci"
    t.string "filename", null: false, collation: "utf8mb4_unicode_ci"
    t.string "content_type", collation: "utf8mb4_unicode_ci"
    t.text "metadata", collation: "utf8mb4_unicode_ci"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false, collation: "utf8mb4_unicode_ci"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "latin1", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "eby_aliases", charset: "latin1", force: :cascade do |t|
    t.integer "eby_def_id", null: false
    t.string "alias", collation: "utf8mb4_unicode_ci"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["eby_def_id"], name: "index_eby_aliases_on_eby_def_id"
  end

  create_table "eby_column_images", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.integer "eby_scan_image_id"
    t.integer "colnum"
    t.string "coljpeg", collation: "utf8mb4_unicode_ci"
    t.string "coldefjpeg", collation: "utf8mb4_unicode_ci"
    t.string "colfootjpeg", collation: "utf8mb4_unicode_ci"
    t.integer "volume"
    t.integer "pagenum"
    t.string "status", collation: "utf8mb4_unicode_ci"
    t.integer "assignedto"
    t.integer "partitioned_by"
    t.string "smalljpeg", collation: "utf8mb4_unicode_ci"
    t.integer "defpartitioner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["eby_scan_image_id", "colnum"], name: "index_eby_column_images_on_eby_scan_image_id_and_colnum"
    t.index ["status", "assignedto"], name: "index_eby_column_images_on_status_and_assignedto"
  end

  create_table "eby_def_events", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.integer "who"
    t.integer "thedef"
    t.string "old_status", collation: "utf8mb4_unicode_ci"
    t.string "new_status", collation: "utf8mb4_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thedef", "new_status"], name: "index_eby_def_events_on_thedef_and_new_status"
  end

  create_table "eby_def_part_images", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.integer "thedef"
    t.integer "partnum"
    t.integer "coldefimg_id"
    t.string "filename", collation: "utf8mb4_unicode_ci"
    t.integer "defno"
    t.boolean "is_last"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thedef"], name: "index_eby_def_part_images_on_thedef"
  end

  create_table "eby_defs", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "defhead", collation: "utf8mb4_unicode_ci"
    t.text "deftext", size: :medium, collation: "utf8mb4_unicode_ci"
    t.integer "assignedto"
    t.string "status", collation: "utf8mb4_unicode_ci"
    t.integer "proof_round_passed"
    t.string "arabic", collation: "utf8mb4_unicode_ci"
    t.string "greek", collation: "utf8mb4_unicode_ci"
    t.string "russian", collation: "utf8mb4_unicode_ci"
    t.string "extra", collation: "utf8mb4_unicode_ci"
    t.text "footnotes", collation: "utf8mb4_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "prob_desc", collation: "utf8mb4_unicode_ci"
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

  create_table "eby_markers", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.integer "user_id"
    t.integer "def_id"
    t.integer "partnum"
    t.integer "marker_y"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "footpart"
    t.integer "footmarker"
  end

  create_table "eby_scan_images", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "origjpeg", collation: "utf8mb4_unicode_ci"
    t.string "smalljpeg", collation: "utf8mb4_unicode_ci"
    t.integer "volume"
    t.integer "firstpagenum"
    t.integer "secondpagenum"
    t.string "status", collation: "utf8mb4_unicode_ci"
    t.integer "assignedto"
    t.integer "partitioned_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignedto"], name: "index_eby_scan_images_on_assignedto"
  end

  create_table "eby_users", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "login", collation: "utf8mb4_unicode_ci"
    t.string "password", collation: "utf8mb4_unicode_ci"
    t.string "fullname", collation: "utf8mb4_unicode_ci"
    t.string "email", collation: "utf8mb4_unicode_ci"
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
    t.string "google_token", collation: "utf8mb4_unicode_ci"
    t.string "google_refresh_token", collation: "utf8mb4_unicode_ci"
    t.string "provider", collation: "utf8mb4_unicode_ci"
    t.string "uid", collation: "utf8mb4_unicode_ci"
    t.string "oauth_token", collation: "utf8mb4_unicode_ci"
    t.datetime "oauth_expires_at"
  end

  create_table "sessions", id: :integer, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "session_id", null: false, collation: "utf8mb4_unicode_ci"
    t.text "data", size: :medium, collation: "utf8mb4_unicode_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id", name: "_fk_rails_c3b3935057"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "eby_aliases", "eby_defs", name: "__fk_rails_f79fdcb449"
end
