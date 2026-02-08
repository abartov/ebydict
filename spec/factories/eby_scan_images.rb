# frozen_string_literal: true

FactoryBot.define do
  factory :eby_scan_image do
    sequence(:origjpeg) { |n| "scan_#{n}.jpg" }
    volume { 1 }
    status { 'NeedPartition' }

    transient do
      base_page { rand(1..500) }
    end

    firstpagenum { base_page }
    secondpagenum { base_page + 1 }

    # Attach test image after creation
    after(:build) do |scan|
      image_path = Rails.root.join('spec', 'fixtures', 'images', 'scan_100x100.jpg')
      if File.exist?(image_path)
        scan.cloud_origjpeg.attach(
          io: File.open(image_path),
          filename: scan.origjpeg,
          content_type: 'image/jpeg'
        )
      end
    end

    trait :with_small_jpeg do
      sequence(:smalljpeg) { |n| "scan_small_#{n}.jpg" }

      after(:build) do |scan|
        image_path = Rails.root.join('spec', 'fixtures', 'images', 'small_50x50.jpg')
        if File.exist?(image_path)
          scan.cloud_smalljpeg.attach(
            io: File.open(image_path),
            filename: scan.smalljpeg,
            content_type: 'image/jpeg'
          )
        end
      end
    end

    trait :partitioned do
      status { 'Partitioned' }
      association :partitioner, factory: :eby_user

      with_small_jpeg

      after(:create) do |scan|
        # Create 2 column images by default
        create_list(:eby_column_image, 2, scan: scan, volume: scan.volume)
      end
    end

    trait :assigned do
      association :assignee, factory: :eby_user
    end

    trait :unassigned do
      assignee { nil }
      assignedto { nil }
    end
  end
end
