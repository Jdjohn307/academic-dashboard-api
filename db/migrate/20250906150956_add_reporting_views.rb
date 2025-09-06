class AddReportingViews < ActiveRecord::Migration[8.0]
  def up
    execute "CREATE SCHEMA reporting"

    # 1. Students with their assignment grades for a specific course
    execute <<~SQL
      CREATE VIEW reporting.student_assignment_grades AS
      SELECT
        users.user.id AS user_id,
        users.user.name AS student_name,
        course.course.id AS course_id,
        course.course.name AS course_name,
        assignment.assignment.id AS assignment_id,
        assignment.assignment.title AS assignment_title,
        assignment.assignment_grade_link.grade,
        assignment.assignment_grade_link.points,
        users.grade.final_grade
      FROM users.user
      JOIN users.user_role_link ON users.user_role_link.user_id = users.user.id
      JOIN users.role ON users.role.id = users.user_role_link.role_id 
        AND users.role.name ILIKE 'student'
      JOIN users.grade ON users.grade.user_id = users.user.id
      JOIN course.course ON course.course.id = users.grade.course_id
      JOIN course.course_schedule ON course.course_schedule.course_id = course.course.id
      JOIN assignment.assignment ON assignment.assignment.course_schedule_id = course.course_schedule.id
      LEFT JOIN assignment.assignment_grade_link  ON assignment.assignment_grade_link.assignment_id = assignment.assignment.id 
        AND assignment.assignment_grade_link.grade_id = users.grade.id
      WHERE users.user.status ILIKE 'Active'
        AND users.user_role_link.status ILIKE 'Active'
      ;
    SQL

    # 2. Student schedule (user with their courses/schedules)
    execute <<~SQL
      CREATE VIEW reporting.student_course_schedule AS
      SELECT
        users.user.id AS user_id,
        users.user.name AS student_name,
        course.course.id AS course_id,
        course.course.name AS course_name,
        course.course_schedule.id AS course_schedule_id,
        course.course_schedule.name AS schedule_name,
        course.course_schedule.start_date,
        course.course_schedule.end_date,
        course.course_schedule.schedule_json
      FROM users.user
      JOIN users.user_role_link ON users.user_role_link.user_id = users.user.id
      JOIN users.role ON users.role.id = users.user_role_link.role_id 
        AND users.role.name ILIKE 'student'
      JOIN course.course_schedule_link ON course.course_schedule_link.user_id = users.user.id
      JOIN course.course_schedule ON course.course_schedule.id = course.course_schedule_link.course_schedule_id
      JOIN course.course ON course.course.id = course.course_schedule.course_id
      WHERE users.user.status ILIKE 'Active'
        AND users.user_role_link.status ILIKE 'Active'
        AND course.course.status ILIKE 'Active'
        AND course.course_schedule.status ILIKE 'Active'
      ;
    SQL

    # 3. Instructor with all their classes for the semester
    execute <<~SQL
      CREATE VIEW reporting.instructor_classes AS
      SELECT
        users.user.id AS instructor_id,
        users.user.name AS instructor_name,
        course.course.id AS course_id,
        course.course.name AS course_name,
        course.course_schedule.id AS course_schedule_id,
        course.course_schedule.name AS schedule_name,
        course.course.semester,
        course.course.year
      FROM users.user
      JOIN users.user_role_link ON users.user_role_link.user_id = users.user.id
      JOIN users.role ON users.role.id = users.user_role_link.role_id 
        AND users.role.name ILIKE 'instructor'
      JOIN course.course_schedule_link ON course.course_schedule_link.user_id = users.user.id
      JOIN course.course_schedule ON course.course_schedule.id = course.course_schedule_link.course_schedule_id
      JOIN course.course ON course.course.id = course.course_schedule.course_id
      WHERE users.user.status ILIKE 'Active'
        AND users.user_role_link.status ILIKE 'Active'
        AND course.course.status ILIKE 'Active'
        AND course.course_schedule.status ILIKE 'Active'
      ;
    SQL

    # 4. Instructor with all their students for the class
    execute <<~SQL
      CREATE VIEW reporting.instructor_students AS
      SELECT
        instructor.id AS instructor_id,
        instructor.name AS instructor_name,
        course.course.id AS course_id,
        course.course.name AS course_name,
        student.id AS student_id,
        student.name AS student_name
      FROM users.user instructor
      JOIN users.user_role_link instructor_role_link ON instructor_role_link.user_id = instructor.id
      JOIN users.role instructor_role ON instructor_role.id = instructor_role_link.role_id 
        AND instructor_role.name = 'instructor'
      JOIN course.course_schedule_link instructor_course_link ON instructor_course_link.user_id = instructor.id
      JOIN course.course_schedule ON course.course_schedule.id = instructor_course_link.course_schedule_id
      JOIN course.course ON course.course.id = course.course_schedule.course_id
      JOIN course.course_schedule_link student_course_link ON student_course_link.course_schedule_id = course.course_schedule.id
      JOIN users.user student ON student.id = student_course_link.user_id
      JOIN users.user_role_link student_role_link ON student_role_link.user_id = student.id
      JOIN users.role student_role ON student_role.id = student_role_link.role_id 
        AND student_role.name = 'student'
      WHERE instructor.status ILIKE 'Active'
        AND instructor_role_link.status ILIKE 'Active'
        AND course.course.status ILIKE 'Active'
        AND course.course_schedule.status ILIKE 'Active'
        AND student_course_link.status ILIKE 'Active'
        AND instructor_course_link.status ILIKE 'Active'
      ;
    SQL

    # 5. Instructor with all ungraded assignments for their class
    execute <<~SQL
      CREATE VIEW reporting.instructor_ungraded_assignments AS
      SELECT
        users.user.id AS instructor_id,
        users.user.name AS instructor_name,
        course.course.id AS course_id,
        course.course.name AS course_name,
        assignment.assignment.id AS assignment_id,
        assignment.assignment.title AS assignment_title,
        assignment.assignment.due_date
      FROM users.user
      JOIN users.user_role_link ON users.user_role_link.user_id = users.user.id
      JOIN users.role ON users.role.id = users.user_role_link.role_id 
        AND users.role.name = 'instructor'
      JOIN course.course_schedule_link ON course.course_schedule_link.user_id = users.user.id
      JOIN course.course_schedule ON course.course_schedule.id = course.course_schedule_link.course_schedule_id
      JOIN course.course ON course.course.id = course.course_schedule.course_id
      JOIN assignment.assignment ON assignment.assignment.course_schedule_id = course.course_schedule.id
      LEFT JOIN assignment.assignment_grade_link ON assignment.assignment_grade_link.assignment_id = assignment.assignment.id
       WHERE users.user.status ILIKE 'Active'
        AND users.user_role_link.status ILIKE 'Active'
        AND course.course.status ILIKE 'Active'
        AND course.course_schedule.status ILIKE 'Active' 
        AND assignment.assignment_grade_link.id IS NULL
      ;
    SQL
  end

  def down
    execute "DROP SCHEMA reporting CASCADE"
    # execute "DROP VIEW IF EXISTS users.student_assignment_grades;"
    # execute "DROP VIEW IF EXISTS users.student_course_schedule;"
    # execute "DROP VIEW IF EXISTS users.instructor_classes;"
    # execute "DROP VIEW IF EXISTS users.instructor_students;"
    # execute "DROP VIEW IF EXISTS users.instructor_ungraded_assignments;"
  end
end
