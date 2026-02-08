# frozen_string_literal: true

FactoryBot.define do
  factory :eby_user do
    sequence(:login) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:fullname) { |n| "Test User #{n}" }
    password { EbyUser.hashfunc('password123') }
    login_count { 0 }

    # Default: no roles
    role_partitioner { false }
    role_typist { false }
    role_proofer { false }
    role_fixer { false }
    role_publisher { false }

    # Default: no language capabilities
    does_arabic { false }
    does_greek { false }
    does_russian { false }
    does_extra { false }

    # Role traits
    trait :partitioner do
      role_partitioner { true }
    end

    trait :typist do
      role_typist { true }
    end

    trait :proofer do
      role_proofer { true }
      max_proof_level { 1 }
    end

    trait :fixer do
      role_fixer { true }
    end

    trait :publisher do
      role_publisher { true }
    end

    trait :admin do
      role_partitioner { true }
      role_typist { true }
      role_proofer { true }
      role_fixer { true }
      role_publisher { true }
      max_proof_level { 3 }
    end

    # Language capability traits
    trait :with_arabic do
      does_arabic { true }
    end

    trait :with_greek do
      does_greek { true }
    end

    trait :with_russian do
      does_russian { true }
    end

    trait :with_extra do
      does_extra { true }
    end

    trait :with_all_languages do
      does_arabic { true }
      does_greek { true }
      does_russian { true }
      does_extra { true }
    end

    # Proof level traits
    trait :proof_level_1 do
      max_proof_level { 1 }
    end

    trait :proof_level_2 do
      max_proof_level { 2 }
    end

    trait :proof_level_3 do
      max_proof_level { 3 }
    end

    # OAuth traits
    trait :from_google_oauth do
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "google_uid_#{n}" }
      oauth_token { SecureRandom.hex(32) }
      oauth_expires_at { 1.hour.from_now }
    end

    trait :with_login_history do
      login_count { rand(1..50) }
      last_login { rand(1..30).days.ago }
    end
  end
end
