class EnsureIdIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index "users.user", :id unless index_exists?("users.user", :id)
    add_index "users.role", :id unless index_exists?("users.role", :id)
    add_index "users.grade", :id unless index_exists?("users.grade", :id)
    add_index "users.user_role_link", :id unless index_exists?("users.user_role_link", :id)
    add_index "course.course", :id unless index_exists?("course.course", :id)
    add_index "course.course_schedule", :id unless index_exists?("course.course_schedule", :id)
    add_index "course.course_schedule_link", :id unless index_exists?("course.course_schedule_link", :id)
    add_index "course.course_schedule_override", :id unless index_exists?("course.course_schedule_override", :id)
    add_index "assignment.assignment", :id unless index_exists?("assignment.assignment", :id)
    add_index "assignment.assignment_grade_link", :id unless index_exists?("assignment.assignment_grade_link", :id)
  end
end
