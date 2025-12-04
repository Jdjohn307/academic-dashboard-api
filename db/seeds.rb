# db/seeds.rb
require 'faker'

raise "Seeds should not be run in production!" and return if Rails.env.production?


# Helper method to generate valid schedule JSON
def generate_schedule_json
  days = %w[monday tuesday wednesday thursday friday]
  schedule = {}

  days.sample(rand(2..4)).each do |day|
    periods = rand(1..2).times.map do
      start_hour = rand(8..14)
      end_hour = start_hour + rand(1..3)
      {
        "start" => format("%02d:00", start_hour),
        "end" => format("%02d:00", end_hour)
      }
    end
    schedule[day] = periods
  end

  schedule
end

# Clear existing data upon re-running the seed
puts "Clearing existing data..."

tables = ActiveRecord::Base.connection.query(<<~SQL)
  SELECT table_schema, table_name#{' '}
  FROM information_schema.tables
  WHERE table_type = 'BASE TABLE' AND#{' '}
    table_schema NOT IN ('pg_catalog', 'information_schema') AND
    table_name NOT IN ('ar_internal_metadata', 'schema_migrations')
SQL

tables.each do |schema, table|
  qualified =("#{schema}.#{table}")

  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{qualified} RESTART IDENTITY CASCADE;")
end

puts "Starting data seed..."

# 1. Create Roles
puts "Creating roles..."
roles_data = [
  { name: "Administrator", status: "active" },
  { name: "Teacher", status: "active" },
  { name: "Teaching Assistant", status: "active" },
  { name: "Student", status: "active" },
  { name: "General Staff", status: "active" }
]

roles = roles_data.map do |role_attrs|
  Api::Users::Role.create!(role_attrs)
end

puts "  Created #{roles.count} roles"

# 2. Create Users
puts "Creating users..."
users = []

# Create all 67 users at once
67.times do
  users << Api::Users::User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "SecurePassword123!",
    password_confirmation: "SecurePassword123!",
    status: "active"
  )
end

puts "  Created #{users.count} users"

# 3. Assign Roles to Users
puts "Assigning roles..."
admin_role = roles.find { |r| r.name == "Administrator" }
teacher_role = roles.find { |r| r.name == "Teacher" }
ta_role = roles.find { |r| r.name == "Teaching Assistant" }
student_role = roles.find { |r| r.name == "Student" }
staff_role = roles.find { |r| r.name == "General Staff" }

role_assignments = [
  { users: users[0..1], role: admin_role },      # 2 admins
  { users: users[2..9], role: teacher_role },    # 8 teachers
  { users: users[10..13], role: ta_role },       # 4 TAs
  { users: users[14..63], role: student_role },  # 50 students
  { users: users[64..66], role: staff_role }     # 3 staff
]

role_assignments.each do |assignment|
  assignment[:users].each do |user|
    Api::Users::UserRoleLink.create!(
      user: user,
      role: assignment[:role],
      status: "active"
    )
  end
end

puts "  Assigned #{Api::Users::UserRoleLink.count} roles"

# 4. Create Courses
puts "Creating courses..."

courses = []
subjects = [ "Computer Science", "Mathematics", "Physics", "Chemistry", "Biology",
            "English Literature", "History", "Economics", "Psychology", "Art" ]
course_levels = [ 101, 201, 301, 401 ]
semesters = [ "fall", "spring", "summer", "winter" ]
current_year = Date.today.year

subjects.each do |subject|
  course_levels.sample(2).each do |level|
    courses << Api::Course::Course.create!(
      name: "#{subject} #{level}",
      semester: semesters.sample,
      year: [ current_year - 1, current_year, current_year + 1 ].sample,
      code: "#{subject.split.map(&:first).join}#{level}",
      status: "active"
    )
  end
end

puts "  Created #{courses.count} courses"

# 5. Create Course Schedules
puts "Creating course schedules..."
course_schedules = []
teachers = users[2..9]

courses.each do |course|
  # Each course gets 1-2 schedules (for different sections)
  rand(1..2).times do |section_num|
    start_date = Faker::Date.between(from: 60.days.ago, to: 30.days.ago)
    end_date = start_date + rand(90..120).days

    course_schedules << Api::Course::CourseSchedule.create!(
      name: "Section #{('A'.ord + section_num).chr}",
      course: course,
      start_date: start_date,
      end_date: end_date,
      schedule_json: generate_schedule_json,
      status: "active"
    )
  end
end

puts "  Created #{course_schedules.count} course schedules"

# 6. Assign Teachers to Course Schedules
puts "Assigning teachers to courses..."
course_schedules.each do |schedule|
  teacher = teachers.sample
  Api::Course::CourseScheduleLink.create!(
    user: teacher,
    course_schedule: schedule,
    status: "active"
  )
end

# 7. Enroll Students in Courses
puts "Enrolling students..."
students = users[14..63]

students.each do |student|
  # Each student enrolls in 3-5 courses
  course_schedules.sample(rand(3..5)).each do |schedule|
    Api::Course::CourseScheduleLink.create!(
      user: student,
      course_schedule: schedule,
      status: "active"
    )
  end
end

puts "  Created #{Api::Course::CourseScheduleLink.count} course schedule links"

# 8. Create Course Schedule Overrides
puts "Creating schedule overrides..."
overrides_count = 0

course_schedules.sample(course_schedules.count / 3).each do |schedule|
  # Create 1-2 overrides per selected schedule
  rand(1..2).times do
    override_date = Faker::Date.between(from: schedule.start_date, to: schedule.end_date)

    Api::Course::CourseScheduleOverride.create!(
      course_schedule: schedule,
      override_date: override_date,
      schedule_json: generate_schedule_json,
      notes: [ "Holiday adjustment", "Special event", "Guest lecturer",
              "Exam day", "Lab session" ].sample,
      status: "active"
    )
    overrides_count += 1
  end
end

puts "  Created #{overrides_count} schedule overrides"

# 9. Create Grades for Enrolled Students
puts "Creating grades..."
grades = []

Api::Course::CourseScheduleLink.where(user: students).each do |enrollment|
  # Create a grade record for each student-course combination
  grades << Api::Users::Grade.create!(
    user: enrollment.user,
    course: enrollment.course_schedule.course,
    final_grade: nil, # Will be calculated from assignments
    comments: nil,
    status: "active"
  )
end

puts "  Created #{grades.count} grade records"

# 10. Create Assignments
puts "Creating assignments..."
assignments = []

course_schedules.each do |schedule|
  # Each course gets 5-8 assignments
  rand(5..8).times do |i|
    due_date = Faker::Date.between(
      from: schedule.start_date + 7.days,
      to: schedule.end_date - 7.days
    )

    assignments << Api::Assignment::Assignment.create!(
      course_schedule: schedule,
      due_date: due_date,
      title: [ "Homework #{i + 1}", "Lab Assignment #{i + 1}", "Project #{i + 1}",
              "Quiz #{i + 1}", "Essay #{i + 1}" ].sample,
      description: Faker::Lorem.paragraph(sentence_count: 2),
      points_possible: [ 50, 75, 100, 150, 200 ].sample,
      status: [ "published", "active" ].sample
    )
  end
end

puts "  Created #{assignments.count} assignments"

# 11. Create Assignment Grade Links (student submissions)
puts "Creating assignment submissions..."
submission_count = 0

assignments.each do |assignment|
  # Find all students enrolled in this course schedule
  enrolled_students = Api::Course::CourseScheduleLink
    .where(course_schedule: assignment.course_schedule)
    .where(user: students)

  enrolled_students.each do |enrollment|
    # Roughly 80% of students submit assignments
    next if rand > 0.8

    # Find the grade record for this student-course
    grade_record = Api::Users::Grade.find_by(
      user: enrollment.user,
      course: assignment.course_schedule.course
    )

    next unless grade_record

    # Random submission date (before or at due date for most)
    submitted_at = assignment.due_date - rand(0..7).days

    # Roughly 70% of submissions are graded
    is_graded = rand < 0.7
    points_earned = is_graded ? rand(0.5..1.0) * assignment.points_possible : nil

    Api::Assignment::AssignmentGradeLink.create!(
      grade_record: grade_record,
      assignment: assignment,
      submitted_at: submitted_at,
      graded_at: is_graded ? submitted_at + rand(1..5).days : nil,
      grade: points_earned ? (points_earned / assignment.points_possible * 100).round(2) : nil,
      points: points_earned&.round(2),
      feedback: is_graded ? Faker::Lorem.sentence(word_count: rand(5..15)) : nil,
      status: is_graded ? "graded" : "submitted"
    )
    submission_count += 1
  end
end

puts "  Created #{submission_count} assignment submissions"

# 12. Calculate Final Grades
puts "Calculating final grades..."
updated_grades = 0

grades.each do |grade|
  # Get all assignment_grade_links for this student's grade record
  # that belong to assignments in the same course
  assignment_links = Api::Assignment::AssignmentGradeLink
    .joins(assignment: { course_schedule: :course })
    .where(grade_record: grade)
    .where("course.id = ?", grade.course_id)
    .where.not(points: nil)

  if assignment_links.any?
    total_points = assignment_links.sum(:points)

    # Get total possible points by joining through to the assignment table
    total_possible = assignment_links
      .joins(:assignment)
      .sum("assignment.points_possible")

    if total_possible > 0
      final_grade = (total_points / total_possible * 100).round(2)
      grade.update!(
        final_grade: final_grade,
        comments: [ "Excellent work!", "Good progress", "Needs improvement",
                   "Outstanding performance", nil ].sample,
        status: "posted"
      )
      updated_grades += 1
    end
  end
end

puts "  Updated #{updated_grades} final grades"

# Summary
puts "\n" + "="*50
puts "Seed completed successfully!"
puts "="*50
puts "Created:"
puts "  - #{Api::Users::Role.count} roles"
puts "  - #{Api::Users::User.count} users"
puts "  - #{Api::Users::UserRoleLink.count} role assignments"
puts "  - #{Api::Course::Course.count} courses"
puts "  - #{Api::Course::CourseSchedule.count} course schedules"
puts "  - #{Api::Course::CourseScheduleLink.count} enrollments"
puts "  - #{Api::Course::CourseScheduleOverride.count} schedule overrides"
puts "  - #{Api::Users::Grade.count} grade records"
puts "  - #{Api::Assignment::Assignment.count} assignments"
puts "  - #{Api::Assignment::AssignmentGradeLink.count} submissions"
puts "\nTest credentials:"
puts "  Admin: #{Api::Users::User.joins(:user_role_links).where(user_role_links: { role: admin_role }).first.email}"
puts "  Teacher: #{Api::Users::User.joins(:user_role_links).where(user_role_links: { role: teacher_role }).first.email}"
puts "  Student: #{Api::Users::User.joins(:user_role_links).where(user_role_links: { role: student_role }).first.email}"
puts "  Password for all: SecurePassword123!"
puts "="*50
