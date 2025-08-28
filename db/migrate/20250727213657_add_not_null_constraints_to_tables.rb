class AddNotNullConstraintsToTables < ActiveRecord::Migration[8.0]
  def change
    # users table
    change_column_null :user, :name, false
    change_column_null :user, :email, false
    change_column_null :user, :encrypted_password, false
    change_column_null :user, :status, true

    # role
    change_column_null :role, :name, false
    change_column_null :role, :status, true

    # user_role_link
    change_column_null :user_role_link, :user_id, false
    change_column_null :user_role_link, :role_id, false
    change_column_null :user_role_link, :status, true

    # course table
    change_column_null :course, :name, false
    change_column_null :course, :semester, false
    change_column_null :course, :year, false
    change_column_null :course, :code, false
    change_column_null :course, :status, true

    # course_schedule
    change_column_null :course_schedule, :name, false
    change_column_null :course_schedule, :course_id, false
    change_column_null :course_schedule, :start_date, false
    change_column_null :course_schedule, :end_date, false
    change_column_null :course_schedule, :status, true

    # course_schedule_link
    change_column_null :course_schedule_link, :user_id, false
    change_column_null :course_schedule_link, :course_schedule_id, false
    change_column_null :course_schedule_link, :status, true

    # course_schedule_override
    change_column_null :course_schedule_override, :course_schedule_id, false
    change_column_null :course_schedule_override, :override_date, false
    change_column_null :course_schedule_override, :schedule_json, false
    change_column_null :course_schedule_override, :status, true

    # assignment
    change_column_null :assignment, :course_schedule_id, false
    change_column_null :assignment, :due_date, false
    change_column_null :assignment, :title, false
    change_column_null :assignment, :points_possible, false
    change_column_null :assignment, :status, true

    # assignment_grade_link
    change_column_null :assignment_grade_link, :assignment_id, false
    change_column_null :assignment_grade_link, :grade_id, false
    change_column_null :assignment_grade_link, :status, true

    # grade
    change_column_null :grade, :user_id, false
    change_column_null :grade, :course_id, false
    change_column_null :grade, :status, true
  end
end
