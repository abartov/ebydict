# frozen_string_literal: true

FactoryBot.define do
  factory :eby_column_image do
    association :scan, factory: :eby_scan_image
    sequence(:colnum)
    sequence(:pagenum) { |n| scan&.firstpagenum || n }
    volume { scan&.volume || 1 }
    status { 'NeedPartition' }

    # Attach test image after creation
    after(:build) do |col|
      image_path = Rails.root.join('spec', 'fixtures', 'images', 'column_80x150.jpg')
      if File.exist?(image_path)
        col.cloud_coljpeg.attach(
          io: File.open(image_path),
          filename: "col_#{col.colnum}.jpg",
          content_type: 'image/jpeg'
        )
      end
    end

    trait :need_def_partition do
      status { 'NeedDefPartition' }
      association :partitioner, factory: :eby_user

      after(:build) do |col|
        # Attach coldefjpeg (definition part) and colfootjpeg (footnote part)
        def_image_path = Rails.root.join('spec', 'fixtures', 'images', 'column_80x150.jpg')
        foot_image_path = Rails.root.join('spec', 'fixtures', 'images', 'def_part_80x50.jpg')

        if File.exist?(def_image_path)
          col.cloud_coldefjpeg.attach(
            io: File.open(def_image_path),
            filename: "coldef_#{col.colnum}.jpg",
            content_type: 'image/jpeg'
          )
        end

        if File.exist?(foot_image_path)
          col.cloud_colfootjpeg.attach(
            io: File.open(foot_image_path),
            filename: "colfoot_#{col.colnum}.jpg",
            content_type: 'image/jpeg'
          )
        end
      end
    end

    trait :partitioned do
      status { 'Partitioned' }
      association :partitioner, factory: :eby_user
      association :defpartitioner, factory: :eby_user

      after(:create) do |col|
        # Create 3 definition parts by default
        3.times do |i|
          create(:eby_def_part_image,
            colimg: col,
            defno: i,
            partnum: i + 1,
            is_last: (i == 2)
          )
        end
      end
    end

    trait :got_orphans do
      status { 'GotOrphans' }
    end

    trait :with_small_jpeg do
      sequence(:smalljpeg) { |n| "col_small_#{n}.jpg" }

      after(:build) do |col|
        image_path = Rails.root.join('spec', 'fixtures', 'images', 'small_50x50.jpg')
        if File.exist?(image_path)
          col.cloud_smalljpeg.attach(
            io: File.open(image_path),
            filename: col.smalljpeg,
            content_type: 'image/jpeg'
          )
        end
      end
    end

    trait :assigned do
      association :assignee, factory: :eby_user
    end
  end
end
