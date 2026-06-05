# frozen_string_literal: true

FactoryBot.define do
  factory :eby_marker do
    association :user, factory: :eby_user
    association :thedef, factory: :eby_def
    partnum { 1 }
    marker_y { rand(10..500) }
    footpart { nil }
    footmarker { nil }

    trait :with_footnote_marker do
      footpart { rand(1..3) }
      footmarker { rand(10..200) }
    end
  end
end
