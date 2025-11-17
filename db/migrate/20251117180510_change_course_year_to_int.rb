class ChangeCourseYearToInt < ActiveRecord::Migration[8.0]
  def up
    # Drop Dependant Views
    execute <<~SQL
      DROP VIEW IF EXISTS reporting.instructor_classes;
    SQL

    # Update Type
    execute <<-SQL
      ALTER TABLE course.course
      ALTER COLUMN year TYPE integer
      USING year::integer;
    SQL

    # Recreate Dependant Views
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
      JOIN users.role ON users.role.id = users.user_role_link.role_id#{' '}
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
  end

  def down
    # Drop Dependant Views
    execute <<~SQL
      DROP VIEW IF EXISTS reporting.instructor_classes;
    SQL

    # Update Type
    execute <<-SQL
      ALTER TABLE course.course
      ALTER COLUMN year TYPE text
      USING year::text;
    SQL

    # Recreate Dependant Views
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
      JOIN users.role ON users.role.id = users.user_role_link.role_id#{' '}
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
  end
end
