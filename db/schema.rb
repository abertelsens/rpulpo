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

ActiveRecord::Schema[7.0].define(version: 2023_04_18_085039) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.integer "lives", default: 1
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
    t.integer "n_agd"
    t.integer "status"
    t.index ["first_name", "family_name"], name: "index_people_on_first_name_and_family_name", unique: true
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
  end

  create_table "personsets", force: :cascade do |t|
    t.integer "peopleset_id"
    t.integer "person_id"
    t.index ["peopleset_id", "person_id"], name: "index_personsets_on_peopleset_id_and_person_id", unique: true
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
  end

end
