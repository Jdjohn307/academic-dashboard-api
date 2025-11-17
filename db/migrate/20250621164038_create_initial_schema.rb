class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def down
    execute "DROP SCHEMA users CASCADE"
    execute "DROP SCHEMA assignment CASCADE"
    execute "DROP SCHEMA course CASCADE"
  end

  def up
    execute "CREATE SCHEMA users"
    execute "CREATE SCHEMA assignment"
    execute "CREATE SCHEMA course"

    create_table "users.user" do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password
      t.string :status
      t.timestamps
    end

    create_table "users.role" do |t|
      t.string :name
      t.string :status
      t.timestamps
    end

    create_table "users.user_role_link" do |t|
      t.references :user, foreign_key: { to_table: "users.user" }
      t.references :role, foreign_key: { to_table: "users.role" }
      t.string :status
      t.timestamps
    end

    create_table "course.course" do |t|
      t.string :name
      t.string :semester
      t.string :year
      t.string :code
      t.string :status
      t.timestamps
    end

    create_table "users.grade" do |t|
      t.references :user, foreign_key: { to_table: "users.user" }
      t.references :course, foreign_key: { to_table: "course.course" }
      t.decimal :final_grade
      t.string :comments
      t.string :status
      t.timestamps
    end

    create_table "course.course_schedule" do |t|
      t.string :name
      t.references :course, foreign_key: { to_table: "course.course" }
      t.datetime :start_date
      t.datetime :end_date
      t.jsonb :schedule_json, default: {}
      t.string :status
      t.timestamps
    end

    create_table "course.course_schedule_link" do |t|
      t.references :user, foreign_key: { to_table: "users.user" }
      t.references :course_schedule, foreign_key: { to_table: "course.course_schedule" }
      t.string :status
      t.timestamps
    end

    create_table "course.course_schedule_override" do |t|
      t.references :course_schedule, foreign_key: { to_table: "course.course_schedule" }
      t.datetime :override_date
      t.jsonb :schedule_json
      t.string :notes
      t.string :status
      t.timestamps
    end

    create_table "assignment.assignment" do |t|
      t.references :course_schedule, foreign_key: { to_table: "course.course_schedule" }
      t.datetime :due_date
      t.string :title
      t.string :description
      t.decimal :points_possible
      t.string :status
      t.timestamps
    end

    create_table "assignment.assignment_grade_link" do |t|
      t.references :grade, foreign_key: { to_table: "users.grade" }
      t.references :assignment, foreign_key: { to_table: "assignment.assignment" }
      t.datetime :submitted_at
      t.datetime :graded_at
      t.decimal :grade
      t.decimal :points
      t.string :feedback
      t.string :status
      t.timestamps
    end
  end
end
