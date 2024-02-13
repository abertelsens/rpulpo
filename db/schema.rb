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

ActiveRecord::Schema[7.0].define(version: 2024_02_04_154024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer "mail_id"
    t.integer "answer_id"
  end

  create_table "assigned_mails", force: :cascade do |t|
    t.integer "mail_id"
    t.integer "user_id"
  end

  create_table "crs", force: :cascade do |t|
    t.integer "person_id"
    t.string "classnumber"
    t.date "pa"
    t.date "admision"
    t.date "oblacion"
    t.date "fidelidad"
    t.date "letter"
    t.date "admissio"
    t.date "presbiterado"
    t.date "diaconado"
    t.date "acolitado"
    t.date "lectorado"
    t.string "cipna"
    t.string "notes"
    t.index ["person_id"], name: "index_crs_on_person_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.integer "pulpo_module_id"
    t.string "description"
    t.integer "engine"
    t.string "path"
    t.boolean "template_variables"
  end

  create_table "entities", force: :cascade do |t|
    t.string "sigla"
    t.string "name"
    t.string "path"
  end

  create_table "mail_files", force: :cascade do |t|
    t.integer "mail_id"
    t.string "name"
    t.string "href"
    t.string "extension"
  end

  create_table "mails", force: :cascade do |t|
    t.integer "entity_id"
    t.date "date"
    t.string "topic"
    t.string "protocol"
    t.string "base_path"
    t.integer "direction"
    t.integer "mail_status"
    t.string "assigned_users"
    t.string "refs_string"
    t.string "ans_string"
  end

  create_table "module_users", force: :cascade do |t|
    t.integer "pulpo_module_id"
    t.integer "user_id"
    t.integer "modulepermission"
  end

  create_table "people", force: :cascade do |t|
    t.string "title"
    t.string "first_name", null: false
    t.string "family_name", null: false
    t.string "short_name", null: false
    t.string "full_name", null: false
    t.string "nominative"
    t.string "accussative"
    t.string "full_info"
    t.string "group"
    t.string "clothes"
    t.string "year"
    t.integer "ctr", default: 1
    t.integer "n_agd", default: 0
    t.integer "status", default: 0
    t.boolean "arrived", default: true
    t.boolean "cavabianca", default: true
    t.date "arrival"
    t.date "departure"
    t.boolean "teacher", default: false
    t.date "birth"
    t.string "celebration_info"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.integer "vela"
  end

  create_table "peoplesets", force: :cascade do |t|
    t.integer "status"
    t.string "name"
  end

  create_table "personals", force: :cascade do |t|
    t.integer "person_id"
    t.string "photo_path"
    t.string "region_of_origin"
    t.string "region"
    t.string "city"
    t.string "languages"
    t.string "father_name"
    t.string "mother_name"
    t.string "parents_address"
    t.string "parents_work"
    t.string "parents_info"
    t.string "siblings_info"
    t.string "economic_info"
    t.string "medical_info"
    t.string "notes"
    t.index ["person_id"], name: "index_personals_on_person_id"
  end

  create_table "personsets", force: :cascade do |t|
    t.integer "peopleset_id"
    t.integer "person_id"
    t.index ["peopleset_id", "person_id"], name: "index_personsets_on_peopleset_id_and_person_id", unique: true
  end

  create_table "pulpo_modules", force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.string "description"
  end

  create_table "references", force: :cascade do |t|
    t.integer "mail_id"
    t.integer "reference_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "house"
    t.string "room"
    t.integer "person_id"
    t.integer "bed"
    t.string "floor"
    t.string "matress"
    t.integer "bathroom"
    t.integer "phone"
  end

  create_table "studies", force: :cascade do |t|
    t.integer "person_id"
    t.string "civil_studies"
    t.string "studies_name"
    t.string "degree"
    t.string "profesional_experience"
    t.string "year_of_studies"
    t.string "faculty"
    t.string "status"
    t.string "licence"
    t.string "doctorate"
    t.string "thesis"
    t.index ["person_id"], name: "index_studies_on_person_id"
  end

  create_table "unread_mails", force: :cascade do |t|
    t.integer "mail_id"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uname"
    t.string "password"
    t.integer "usertype"
    t.boolean "mail"
  end

  create_table "velas", force: :cascade do |t|
    t.date "date"
    t.datetime "start_time"
    t.datetime "start_time2"
    t.datetime "end_time"
    t.string "start1_message"
    t.string "start2_message"
    t.string "end_message"
    t.string "order"
  end

end
