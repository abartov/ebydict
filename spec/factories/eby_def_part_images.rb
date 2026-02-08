# frozen_string_literal: true

FactoryBot.define do
  factory :eby_def_part_image do
    association :colimg, factory: :eby_column_image
    association :eby_def, factory: :eby_def
    sequence(:defno)
    sequence(:partnum)
    is_last { false }

    # Attach test image after creation
    after(:build) do |part|
      image_path = Rails.root.join('spec', 'fixtures', 'images', 'def_part_80x50.jpg')
      if File.exist?(image_path)
        part.cloud_defpartjpeg.attach(
          io: File.open(image_path),
          filename: "defpart_#{part.partnum}.jpg",
          content_type: 'image/jpeg'
        )
      end
    end

    trait :last_part do
      is_last { true }
    end

    trait :orphan do
      eby_def { nil }
      thedef { nil }
    end
  end
end
