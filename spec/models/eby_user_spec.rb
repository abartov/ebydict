# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyUser, type: :model do
  describe 'associations' do
    it { should have_many(:eby_def_events).with_foreign_key('who') }
    # Note: eby_defs association uses non-standard naming (source: :thedef)
    # Testing it manually below instead of with shoulda-matchers
    it 'has many eby_defs through eby_def_events' do
      expect(described_class.reflect_on_association(:eby_defs)).to be_present
      expect(described_class.reflect_on_association(:eby_defs).macro).to eq(:has_many)
    end
    it { should have_many(:assigned_defs).class_name('EbyDef').with_foreign_key('assignedto') }
    it { should have_many(:typed_defs).class_name('EbyDef').through(:eby_def_events) }
    it { should have_many(:proofed_defs).class_name('EbyDef').through(:eby_def_events) }
    it { should have_many(:first_proofed_defs).class_name('EbyDef').through(:eby_def_events) }
    it { should have_many(:second_proofed_defs).class_name('EbyDef').through(:eby_def_events) }
    it { should have_many(:fixed_defs).class_name('EbyDef').through(:eby_def_events) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:does_arabic).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:does_extra).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:does_greek).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:does_russian).in_array([true, false]).allow_nil }

    it { should validate_inclusion_of(:role_fixer).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:role_partitioner).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:role_proofer).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:role_publisher).in_array([true, false]).allow_nil }
    it { should validate_inclusion_of(:role_typist).in_array([true, false]).allow_nil }

    it { should validate_numericality_of(:max_proof_level).allow_nil }
    it { should validate_presence_of(:fullname) }
    it { should validate_length_of(:fullname).is_at_least(3) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:email).is_at_least(5) }
  end

  describe '.authenticate' do
    let!(:user) { create(:eby_user, login: 'testuser', email: 'test@example.com', password: EbyUser.hashfunc('password123')) }

    context 'with valid login credentials' do
      it 'returns the user when login matches' do
        expect(EbyUser.authenticate('testuser', 'password123')).to eq(user)
      end

      it 'returns the user when email matches' do
        expect(EbyUser.authenticate('test@example.com', 'password123')).to eq(user)
      end
    end

    context 'with invalid credentials' do
      it 'returns nil for wrong password' do
        expect(EbyUser.authenticate('testuser', 'wrongpassword')).to be_nil
      end

      it 'returns nil for non-existent user' do
        expect(EbyUser.authenticate('nonexistent', 'password123')).to be_nil
      end
    end

    context 'when an exception occurs' do
      it 'returns nil gracefully' do
        allow(EbyUser).to receive(:find_by_login).and_raise(StandardError)
        expect(EbyUser.authenticate('testuser', 'password123')).to be_nil
      end
    end
  end

  describe '.hashfunc' do
    it 'returns a SHA1 hash' do
      result = EbyUser.hashfunc('testpassword')
      expect(result).to be_a(String)
      expect(result.length).to eq(40)
    end

    it 'returns consistent hash for same input' do
      hash1 = EbyUser.hashfunc('testpassword')
      hash2 = EbyUser.hashfunc('testpassword')
      expect(hash1).to eq(hash2)
    end

    it 'returns different hashes for different inputs' do
      hash1 = EbyUser.hashfunc('password1')
      hash2 = EbyUser.hashfunc('password2')
      expect(hash1).not_to eq(hash2)
    end

    it 'uses the salt "Moose2402--"' do
      # The hash should be based on "Moose2402--{str}--"
      expected = Digest::SHA1.hexdigest("Moose2402--test--")[0..39]
      expect(EbyUser.hashfunc('test')).to eq(expected)
    end
  end

  describe '.from_omniauth' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          name: 'John Doe',
          email: 'john@example.com'
        },
        credentials: {
          token: 'mock_token',
          expires_at: Time.now.to_i + 3600
        }
      })
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          EbyUser.from_omniauth(auth_hash)
        }.to change(EbyUser, :count).by(1)
      end

      it 'sets the user attributes from OAuth' do
        user = EbyUser.from_omniauth(auth_hash)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user.fullname).to eq('John Doe')
        expect(user.email).to eq('john@example.com')
        expect(user.oauth_token).to eq('mock_token')
      end

      it 'sets role_typist to true for new users' do
        user = EbyUser.from_omniauth(auth_hash)
        expect(user.role_typist).to be true
      end
    end

    context 'when user exists with same email' do
      let!(:existing_user) { create(:eby_user, email: 'john@example.com', login: 'johndoe') }

      it 'does not create a new user' do
        expect {
          EbyUser.from_omniauth(auth_hash)
        }.not_to change(EbyUser, :count)
      end

      it 'merges OAuth data into existing user' do
        user = EbyUser.from_omniauth(auth_hash)
        expect(user.id).to eq(existing_user.id)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user.oauth_token).to eq('mock_token')
      end

      it 'updates the fullname from OAuth' do
        user = EbyUser.from_omniauth(auth_hash)
        expect(user.fullname).to eq('John Doe')
      end
    end

    context 'when user exists with same provider and uid' do
      let!(:existing_user) do
        create(:eby_user, :from_google_oauth,
          provider: 'google_oauth2',
          uid: '123456789',
          email: 'old@example.com'
        )
      end

      it 'does not create a new user' do
        expect {
          EbyUser.from_omniauth(auth_hash)
        }.not_to change(EbyUser, :count)
      end

      it 'updates the user data' do
        user = EbyUser.from_omniauth(auth_hash)
        expect(user.id).to eq(existing_user.id)
        expect(user.email).to eq('john@example.com')
      end
    end
  end

  describe '#list_roles' do
    it 'returns empty string when no roles assigned' do
      user = create(:eby_user)
      expect(user.list_roles).to eq('')
    end

    it 'lists partitioner role' do
      user = create(:eby_user, :partitioner)
      expect(user.list_roles).to include(I18n.t(:user_partitioner))
    end

    it 'lists typist role' do
      user = create(:eby_user, :typist)
      expect(user.list_roles).to include(I18n.t(:user_typist))
    end

    it 'lists proofer role with max proof level' do
      user = create(:eby_user, :proofer, max_proof_level: 2)
      expect(user.list_roles).to include(I18n.t(:user_proofer))
      expect(user.list_roles).to include(I18n.t(:user_proofs_up_to))
      expect(user.list_roles).to include('2')
    end

    it 'lists fixer role' do
      user = create(:eby_user, :fixer)
      expect(user.list_roles).to include(I18n.t(:user_fixer))
    end

    it 'lists publisher role' do
      user = create(:eby_user, :publisher)
      expect(user.list_roles).to include(I18n.t(:user_publisher))
    end

    it 'lists multiple roles separated by semicolons' do
      user = create(:eby_user, :typist, :fixer)
      roles = user.list_roles
      expect(roles).to include(I18n.t(:user_typist))
      expect(roles).to include(I18n.t(:user_fixer))
      expect(roles).to include('; ')
    end
  end
end
