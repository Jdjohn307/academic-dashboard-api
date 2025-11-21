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

ActiveRecord::Schema[8.0].define(version: 2025_11_21_184340) do
  create_schema "assignment"
  create_schema "course"
  create_schema "reporting"
  create_schema "users"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assignment", force: :cascade do |t|
    t.bigint "course_schedule_id", null: false
    t.datetime "due_date", null: false
    t.string "title", null: false
    t.string "description"
    t.decimal "points_possible", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_schedule_id"], name: "index_assignment_on_course_schedule_id"
    t.index ["id"], name: "index_assignment_on_id"
  end

  create_table "assignment_grade_link", force: :cascade do |t|
    t.bigint "grade_id", null: false
    t.bigint "assignment_id", null: false
    t.datetime "submitted_at"
    t.datetime "graded_at"
    t.decimal "grade"
    t.decimal "points"
    t.string "feedback"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_assignment_grade_link_on_assignment_id"
    t.index ["grade_id"], name: "index_assignment_grade_link_on_grade_id"
    t.index ["id"], name: "index_assignment_grade_link_on_id"
  end

  create_table "course", force: :cascade do |t|
    t.string "name", null: false
    t.string "semester", null: false
    t.integer "year", null: false
    t.string "code", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_course_on_id"
  end

  create_table "course_schedule", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "course_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.jsonb "schedule_json", default: {}
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_schedule_on_course_id"
    t.index ["id"], name: "index_course_schedule_on_id"
  end

  create_table "course_schedule_link", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_schedule_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_schedule_id"], name: "index_course_schedule_link_on_course_schedule_id"
    t.index ["id"], name: "index_course_schedule_link_on_id"
    t.index ["user_id"], name: "index_course_schedule_link_on_user_id"
  end

  create_table "course_schedule_override", force: :cascade do |t|
    t.bigint "course_schedule_id", null: false
    t.datetime "override_date", null: false
    t.jsonb "schedule_json", null: false
    t.string "notes"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_schedule_id"], name: "index_course_schedule_override_on_course_schedule_id"
    t.index ["id"], name: "index_course_schedule_override_on_id"
  end

  create_table "grade", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.decimal "final_grade"
    t.string "comments"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_grade_on_course_id"
    t.index ["id"], name: "index_grade_on_id"
    t.index ["user_id"], name: "index_grade_on_user_id"
  end

  create_table "role", force: :cascade do |t|
    t.string "name", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_role_on_id"
  end

  create_table "test_tables", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_user_on_id"
  end

  create_table "user_role_link", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_user_role_link_on_id"
    t.index ["role_id"], name: "index_user_role_link_on_role_id"
    t.index ["user_id"], name: "index_user_role_link_on_user_id"
  end

  add_foreign_key "assignment", "course_schedule"
  add_foreign_key "assignment_grade_link", "assignment"
  add_foreign_key "assignment_grade_link", "grade"
  add_foreign_key "course_schedule", "course"
  add_foreign_key "course_schedule_link", "course_schedule"
  add_foreign_key "course_schedule_link", "user"
  add_foreign_key "course_schedule_override", "course_schedule"
  add_foreign_key "grade", "course"
  add_foreign_key "grade", "user"
  add_foreign_key "user_role_link", "role"
  add_foreign_key "user_role_link", "user"
end
