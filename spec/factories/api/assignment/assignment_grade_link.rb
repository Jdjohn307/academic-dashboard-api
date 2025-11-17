FactoryBot.define do
  factory :assignment_grade_link, class: 'Api::Assignment::AssignmentGradeLink' do
    association :grade_record
    association :assignment
    submitted_at { Time.now - 2.days }
    graded_at { Time.now - 1.day }
    grade { 85.0 }
    points { 85.0 }
    feedback { "Good work." }
    status { "graded" }
  end

  factory :assignment_grade_link_invalid_points, class: 'Api::Assignment::AssignmentGradeLink' do
    association :grade_record
    association :assignment
    submitted_at { Time.now - 2.days }
    graded_at { Time.now - 1.day }
    grade { 85.0 }
    points { 999.0 }
    feedback { "Good work." }
    status { "graded" }
  end
end
