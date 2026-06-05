# frozen_string_literal: true

FactoryBot.define do
  factory :eby_alias do
    association :eby_def
    sequence(:alias) { |n| "כינוי#{n}" } # Hebrew: "Alias N"

    trait :stripped_nikkud do
      # Simulate nikkud stripping
      after(:build) do |alias_record|
        # The alias would normally be the headword without nikkud marks
        alias_record.alias = alias_record.eby_def&.defhead&.gsub(/[\u0591-\u05C7]/, '') if alias_record.eby_def
      end
    end
  end
end
