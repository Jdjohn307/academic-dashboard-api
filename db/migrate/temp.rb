# Template for adding triggers
class AddTriggerToCourse < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION set_course_slug()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.slug := lower(replace(NEW.name, ' ', '-'));
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER trigger_set_course_slug
      BEFORE INSERT ON course
      FOR EACH ROW
      EXECUTE FUNCTION set_course_slug();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS trigger_set_course_slug ON course;
      DROP FUNCTION IF EXISTS set_course_slug();
    SQL
  end
end
