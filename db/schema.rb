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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170917102410) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "events", force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name",       null: false
    t.string   "logo",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_events_on_code", unique: true, using: :btree
  end

  create_table "gift_cards", force: :cascade do |t|
    t.string   "store",      null: false
    t.string   "url",        null: false
    t.string   "challenge",  null: false
    t.bigint   "number",     null: false
    t.integer  "amount",     null: false
    t.integer  "pairing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pairing_id"], name: "index_gift_cards_on_pairing_id", using: :btree
  end

  create_table "group_members", force: :cascade do |t|
    t.integer  "group_id",    null: false
    t.integer  "question_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["group_id"], name: "index_group_members_on_group_id", using: :btree
    t.index ["question_id", "group_id"], name: "index_group_members_on_question_id_and_group_id", unique: true, using: :btree
    t.index ["question_id"], name: "index_group_members_on_question_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "level",      null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pairings", force: :cascade do |t|
    t.integer  "user_1_id",              null: false
    t.integer  "user_2_id",              null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "message_id"
    t.integer  "status",     default: 0, null: false
    t.index ["user_1_id", "user_2_id"], name: "index_pairings_on_user_1_id_and_user_2_id", unique: true, using: :btree
    t.index ["user_1_id"], name: "index_pairings_on_user_1_id", using: :btree
    t.index ["user_2_id", "user_1_id"], name: "index_pairings_on_user_2_id_and_user_1_id", unique: true, using: :btree
    t.index ["user_2_id"], name: "index_pairings_on_user_2_id", using: :btree
  end

  create_table "preferences", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "yes_label",     null: false
    t.string   "no_label",      null: false
    t.string   "text",          null: false
    t.integer  "preference_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["preference_id"], name: "index_questions_on_preference_id", using: :btree
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_user_groups_on_group_id", using: :btree
    t.index ["user_id", "group_id"], name: "index_user_groups_on_user_id_and_group_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_user_groups_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "first_name",             default: "",   null: false
    t.string   "last_name",              default: "",   null: false
    t.string   "zip"
    t.integer  "supported"
    t.integer  "desired"
    t.text     "background"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "subscribe",              default: true, null: false
    t.json     "geolocation"
    t.string   "ip"
    t.json     "info"
    t.integer  "event_id"
    t.index "email gist_trgm_ops", name: "trgm_email_indx", using: :gist
    t.index "first_name gist_trgm_ops", name: "trgm_first_name_indx", using: :gist
    t.index "last_name gist_trgm_ops", name: "trgm_last_name_indx", using: :gist
    t.index "to_tsvector('english'::regconfig, (email)::text)", name: "users_to_tsvector_idx1", using: :gin
    t.index "to_tsvector('english'::regconfig, (email)::text)", name: "users_to_tsvector_idx4", using: :gin
    t.index "to_tsvector('english'::regconfig, (first_name)::text)", name: "users_to_tsvector_idx2", using: :gin
    t.index "to_tsvector('english'::regconfig, (first_name)::text)", name: "users_to_tsvector_idx5", using: :gin
    t.index "to_tsvector('english'::regconfig, (last_name)::text)", name: "users_to_tsvector_idx3", using: :gin
    t.index "to_tsvector('english'::regconfig, (last_name)::text)", name: "users_to_tsvector_idx6", using: :gin
    t.index "to_tsvector('english'::regconfig, background)", name: "users_to_tsvector_idx", using: :gin
    t.index "zip text_pattern_ops", name: "index_users_on_zip_text_pattern_ops", using: :btree
    t.index ["desired"], name: "index_users_on_desired", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["event_id"], name: "index_users_on_event_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["supported"], name: "index_users_on_supported", using: :btree
    t.index ["zip"], name: "index_users_on_zip", using: :btree
  end

  add_foreign_key "group_members", "groups"
  add_foreign_key "group_members", "questions"
  add_foreign_key "questions", "preferences"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
  add_foreign_key "users", "events"
end
