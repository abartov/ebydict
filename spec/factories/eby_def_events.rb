# frozen_string_literal: true

FactoryBot.define do
  factory :eby_def_event do
    association :user, factory: :eby_user
    association :eby_def, factory: :eby_def
    old_status { 'none' }
    new_status { 'NeedTyping' }

    # Common transition traits
    trait :typing_started do
      old_status { 'none' }
      new_status { 'NeedTyping' }
    end

    trait :typing_completed do
      old_status { 'NeedTyping' }
      new_status { 'NeedProof1' }
    end

    trait :proof1_completed do
      old_status { 'NeedProof1' }
      new_status { 'NeedProof2' }
    end

    trait :proof2_completed do
      old_status { 'NeedProof2' }
      new_status { 'NeedProof3' }
    end

    trait :proof3_completed do
      old_status { 'NeedProof3' }
      new_status { 'NeedPublish' }
    end

    trait :sent_to_fixup do
      old_status { 'NeedProof1' }
      new_status { 'NeedFixup' }
    end

    trait :fixup_completed do
      old_status { 'NeedFixup' }
      new_status { 'NeedProof1' }
    end

    trait :marked_problem do
      old_status { 'NeedTyping' }
      new_status { 'Problem' }
    end

    trait :published do
      old_status { 'NeedPublish' }
      new_status { 'Published' }
    end

    trait :abandoned do
      old_status { 'NeedTyping' }
      new_status { 'NeedTyping' }
    end
  end
end
