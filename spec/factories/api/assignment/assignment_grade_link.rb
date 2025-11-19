FactoryBot.define do
  factory :assignment_grade_link, class: 'Api::Assignment::AssignmentGradeLink' do
    association :grade_record
    association :assignment
    submitted_at { Time.zone.now - 2.days }
    graded_at { Time.zone.now - 1.day }
    grade { 85.0 }
    points { 85.0 }
    feedback { "Good work." }
    status { "graded" }

    # Traits for invalid cases
    trait :assignment_grade_link_invalid_points do
      points do
        999.0
      end
    end
  end
end
