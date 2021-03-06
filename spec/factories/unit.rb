FactoryBot.define do
  factory(:unit) do
    sequence(:name) { |n| "Unit #{n}" }
    association(:complete_curriculum_programme, factory: :ccp)
    summary { "Summary" }
    rationale { "Rationale" }
    guidance { "Guidance" }
    sequence(:position) { |n| n }
    year { [1, 3, 5, 7, 9, 11].sample }

    trait(:randomised) do
      name { Faker::Lorem.word.capitalize }
      association(:complete_curriculum_programme, factory: %i(ccp randomised))
      overview { Faker::Lorem.paragraph }
      benefits { Faker::Lorem.paragraphs.join("\n\n") }
    end

    trait(:with_lessons) do
      transient do
        number_of_lessons { 3 }
      end

      after(:create) do |unit, evaluator|
        create_list(:lesson, evaluator.number_of_lessons, unit: unit)
      end
    end
  end
end
