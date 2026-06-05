# frozen_string_literal: true

FactoryBot.define do
  factory :eby_def do
    sequence(:defhead) { |n| "ערך #{n}" } # Hebrew: "Entry N"
    deftext { "<p>זהו ערך לדוגמה בעברית</p>" } # Hebrew sample text
    status { 'NeedTyping' }
    volume { 1 }
    proof_round_passed { 0 }
    reject_count { 0 }
    arabic { 'none' }
    greek { 'none' }
    russian { 'none' }
    extra { 'none' }
    aliases_done { false }

    # Status traits
    trait :partial do
      status { 'Partial' }
    end

    trait :got_orphans do
      status { 'GotOrphans' }
    end

    trait :need_typing do
      status { 'NeedTyping' }
      proof_round_passed { 0 }
    end

    trait :need_proof_1 do
      status { 'NeedProof' }
      proof_round_passed { 0 }
    end

    trait :need_proof_2 do
      status { 'NeedProof' }
      proof_round_passed { 1 }
    end

    trait :need_proof_3 do
      status { 'NeedProof' }
      proof_round_passed { 2 }
    end

    trait :need_fixup do
      status { 'NeedFixup' }
      proof_round_passed { 3 }
    end

    trait :need_publish do
      status { 'NeedPublish' }
      proof_round_passed { 3 }
    end

    trait :published do
      status { 'Published' }
      proof_round_passed { 3 }
      aliases_done { true }
    end

    trait :problem do
      status { 'Problem' }
      prob_desc { 'Test problem description' }
    end

    # Assignment traits
    trait :assigned do
      association :assignee, factory: :eby_user
    end

    trait :unassigned do
      assignee { nil }
      assignedto { nil }
    end

    # Language work traits
    trait :arabic_todo do
      arabic { 'todo' }
    end

    trait :arabic_done do
      arabic { 'done' }
    end

    trait :greek_todo do
      greek { 'todo' }
    end

    trait :greek_done do
      greek { 'done' }
    end

    trait :russian_todo do
      russian { 'todo' }
    end

    trait :russian_done do
      russian { 'done' }
    end

    trait :extra_todo do
      extra { 'todo' }
    end

    trait :extra_done do
      extra { 'done' }
    end

    # Rejection traits
    trait :rejected_once do
      reject_count { 1 }
    end

    trait :rejected_multiple do
      reject_count { rand(2..5) }
    end

    # Content traits
    trait :with_footnotes do
      footnotes { '<p>הערת שוליים 1</p><p>הערת שוליים 2</p>' } # Hebrew footnotes
    end

    trait :with_rich_content do
      deftext do
        <<~HTML
          <p>זהו <b>ערך</b> עם <i>עיצוב</i> עשיר.</p>
          <p>כולל מקורות: [מ:תנ"ך בראשית א:א]</p>
          <p>ו[ה:הערה חשובה] הערות.</p>
        HTML
      end
    end

    # Size-related traits (number of part_images)
    trait :small do
      after(:create) do |def_instance|
        create(:eby_def_part_image, thedef: def_instance.id, partnum: 1, is_last: true)
      end
    end

    trait :medium do
      after(:create) do |def_instance|
        create(:eby_def_part_image, thedef: def_instance.id, partnum: 1)
        create(:eby_def_part_image, thedef: def_instance.id, partnum: 2, is_last: true)
      end
    end

    trait :large do
      after(:create) do |def_instance|
        (1..5).each do |i|
          create(:eby_def_part_image,
            thedef: def_instance.id,
            partnum: i,
            is_last: (i == 5)
          )
        end
      end
    end

    # Ordinal numbering
    trait :with_ordinal do
      sequence(:ordinal)
    end
  end
end
