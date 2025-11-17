FactoryBot.define do
  factory :grade_record, class: 'Api::Users::Grade' do
    association :user
    association :course
    final_grade { 90.0 }
    comments { "Final grade comment." }
    status { "posted" }
  end
end
