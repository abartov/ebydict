# frozen_string_literal: true

namespace :test_db do
  desc 'Set up test database with SQLite-compatible schema'
  task setup: :environment do
    ActiveRecord::Base.establish_connection(:test)

    # Drop and recreate the test database
    ActiveRecord::Tasks::DatabaseTasks.drop_current('test') rescue nil
    ActiveRecord::Tasks::DatabaseTasks.create_current('test')

    # Load schema without MySQL-specific options
    ActiveRecord::Schema.define(version: 2024_04_19_073729) do
      create_table "active_storage_attachments", force: :cascade do |t|
        t.string "name", null: false
        t.string "record_type", null: false
        t.bigint "record_id", null: false
        t.bigint "blob_id", null: false
        t.datetime "created_at", null: false
        t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
        t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
      end

      create_table "active_storage_blobs", force: :cascade do |t|
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

      create_table "active_storage_variant_records", force: :cascade do |t|
        t.bigint "blob_id", null: false
        t.string "variation_digest", null: false
        t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
      end

      create_table "eby_aliases", force: :cascade do |t|
        t.integer "eby_def_id", null: false
        t.string "alias"
        t.datetime "created_at", precision: 6, null: false
        t.datetime "updated_at", precision: 6, null: false
        t.index ["eby_def_id"], name: "index_eby_aliases_on_eby_def_id"
      end

      create_table "eby_column_images", force: :cascade do |t|
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
        t.index ["eby_scan_image_id", "colnum"], name: "index_eby_column_images_on_eby_scan_image_id_and_colnum"
        t.index ["status", "assignedto"], name: "index_eby_column_images_on_status_and_assignedto"
      end

      create_table "eby_def_events", force: :cascade do |t|
        t.integer "who"
        t.integer "thedef"
        t.string "old_status"
        t.string "new_status"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["thedef", "new_status"], name: "index_eby_def_events_on_thedef_and_new_status"
      end

      create_table "eby_def_part_images", force: :cascade do |t|
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

      create_table "eby_defs", force: :cascade do |t|
        t.string "defhead"
        t.text "deftext"
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
        t.string "prob_desc", limit: 4000
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

      create_table "eby_markers", force: :cascade do |t|
        t.integer "user_id"
        t.integer "def_id"
        t.integer "partnum"
        t.integer "marker_y"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer "footpart"
        t.integer "footmarker"
      end

      create_table "eby_scan_images", force: :cascade do |t|
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
        t.index ["assignedto"], name: "index_eby_scan_images_on_assignedto"
      end

      create_table "eby_users", force: :cascade do |t|
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

      create_table "sessions", force: :cascade do |t|
        t.string "session_id", null: false
        t.text "data"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["session_id"], name: "index_sessions_on_session_id"
        t.index ["updated_at"], name: "index_sessions_on_updated_at"
      end
    end

    puts "Test database setup complete!"
  end
end
