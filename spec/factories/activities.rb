FactoryBot.define do
  factory :activity do
    association :lesson_part, factory: :lesson_part
    sequence(:name) { |n| "Activity #{n}" }
    sequence(:overview) { |n| "Overview #{n}" }
    duration { 20 }
    extra_requirements { ['PVA Glue', 'Glitter'] }
    default { false }

    after :build do |activity|
      if activity.default == nil && activity.lesson_part.activities.none?(&:default?)
        activity.default = true
      end
    end

    trait(:randomised) do
      name { Faker::Lorem.sentence }
      overview { Faker::Lorem.paragraph }
      duration { 20.step(to: 60, by: 5).to_a.sample }
    end
  end
end