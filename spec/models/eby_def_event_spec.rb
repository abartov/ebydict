# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyDefEvent, type: :model do
  describe 'associations' do
    it { should belong_to(:eby_def).with_foreign_key('thedef') }
    it { should belong_to(:user).class_name('EbyUser').with_foreign_key('who') }
  end

  describe 'EbyDefEventValidator' do
    let(:user) { create(:eby_user) }
    let(:eby_def) { create(:eby_def) }

    context 'with valid statuses' do
      it 'accepts "none" as old_status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'none', new_status: 'NeedTyping')
        expect(event).to be_valid
      end

      it 'accepts "Problem" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'Problem')
        expect(event).to be_valid
      end

      it 'accepts "Partial" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'none', new_status: 'Partial')
        expect(event).to be_valid
      end

      it 'accepts "GotOrphans" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'Partial', new_status: 'GotOrphans')
        expect(event).to be_valid
      end

      it 'accepts "NeedTyping" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'Partial', new_status: 'NeedTyping')
        expect(event).to be_valid
      end

      it 'accepts "NeedFixup" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedFixup')
        expect(event).to be_valid
      end

      it 'accepts "NeedPublish" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof3', new_status: 'NeedPublish')
        expect(event).to be_valid
      end

      it 'accepts "Published" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedPublish', new_status: 'Published')
        expect(event).to be_valid
      end
    end

    context 'with NeedProof statuses' do
      it 'accepts "NeedProof1" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
        expect(event).to be_valid
      end

      it 'accepts "NeedProof2" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof2')
        expect(event).to be_valid
      end

      it 'accepts "NeedProof3" status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof2', new_status: 'NeedProof3')
        expect(event).to be_valid
      end

      it 'accepts any NeedProof with digit pattern' do
        # Test that the regex /NeedProof\d+/ works
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof9')
        expect(event).to be_valid
      end

      it 'accepts NeedProof in both old and new status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof2')
        expect(event).to be_valid
      end
    end

    context 'with invalid statuses' do
      it 'rejects nil old_status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: nil, new_status: 'NeedTyping')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include('the status fields cannot be empty')
      end

      it 'rejects nil new_status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping', new_status: nil)
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include('the status fields cannot be empty')
      end

      it 'rejects blank old_status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: '', new_status: 'NeedTyping')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include('the status fields cannot be empty')
      end

      it 'rejects blank new_status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping', new_status: '')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include('the status fields cannot be empty')
      end

      it 'rejects invalid status string' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'InvalidStatus', new_status: 'NeedTyping')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'InvalidStatus' is not a valid status")
      end

      it 'rejects multiple invalid statuses' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'BadStatus', new_status: 'AlsoBad')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'BadStatus' is not a valid status")
        expect(event.errors[:base]).to include("'AlsoBad' is not a valid status")
      end

      it 'rejects NeedProof without digit' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProof', new_status: 'NeedTyping')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'NeedProof' is not a valid status")
      end

      it 'rejects NeedProof with non-digit characters' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedProofX', new_status: 'NeedTyping')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'NeedProofX' is not a valid status")
      end
    end

    context 'with case sensitivity' do
      it 'rejects lowercase status' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'needtyping', new_status: 'NeedProof1')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'needtyping' is not a valid status")
      end

      it 'rejects status with wrong capitalization' do
        event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NEEDTYPING', new_status: 'NeedProof1')
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("'NEEDTYPING' is not a valid status")
      end
    end
  end

  describe 'common status transitions' do
    let(:user) { create(:eby_user) }
    let(:eby_def) { create(:eby_def) }

    it 'records definition creation' do
      event = create(:eby_def_event, :typing_started, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('none')
      expect(event.new_status).to eq('NeedTyping')
    end

    it 'records typing completion' do
      event = create(:eby_def_event, :typing_completed, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedTyping')
      expect(event.new_status).to eq('NeedProof1')
    end

    it 'records first proof completion' do
      event = create(:eby_def_event, :proof1_completed, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedProof1')
      expect(event.new_status).to eq('NeedProof2')
    end

    it 'records second proof completion' do
      event = create(:eby_def_event, :proof2_completed, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedProof2')
      expect(event.new_status).to eq('NeedProof3')
    end

    it 'records third proof completion' do
      event = create(:eby_def_event, :proof3_completed, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedProof3')
      expect(event.new_status).to eq('NeedPublish')
    end

    it 'records sending to fixup' do
      event = create(:eby_def_event, :sent_to_fixup, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedProof1')
      expect(event.new_status).to eq('NeedFixup')
    end

    it 'records fixup completion' do
      event = create(:eby_def_event, :fixup_completed, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedFixup')
      expect(event.new_status).to eq('NeedProof1')
    end

    it 'records marking as problem' do
      event = create(:eby_def_event, :marked_problem, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedTyping')
      expect(event.new_status).to eq('Problem')
    end

    it 'records publishing' do
      event = create(:eby_def_event, :published, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedPublish')
      expect(event.new_status).to eq('Published')
    end

    it 'records abandonment (same status)' do
      event = create(:eby_def_event, :abandoned, user: user, eby_def: eby_def)
      expect(event.old_status).to eq('NeedTyping')
      expect(event.new_status).to eq('NeedTyping')
    end
  end

  describe 'event tracking for workflow' do
    let(:typist) { create(:eby_user, :typist) }
    let(:proofer) { create(:eby_user, :proofer) }
    let(:eby_def) { create(:eby_def, :need_typing) }

    it 'creates event when definition status changes' do
      expect {
        create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      }.to change(EbyDefEvent, :count).by(1)
    end

    it 'records who performed the action' do
      event = create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      expect(event.user).to eq(typist)
      expect(event.who).to eq(typist.id)
    end

    it 'links to the definition' do
      event = create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      expect(event.eby_def).to eq(eby_def)
      expect(event.thedef).to eq(eby_def.id)
    end

    it 'maintains audit trail with timestamps' do
      event = create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      expect(event.created_at).to be_present
      expect(event.updated_at).to be_present
    end

    it 'allows multiple events for same definition' do
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      create(:eby_def_event, user: proofer, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof2')

      expect(eby_def.events.count).to eq(2)
    end

    it 'tracks complete workflow through events' do
      # Typing
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'none', new_status: 'NeedTyping')
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')

      # Proofing rounds
      create(:eby_def_event, user: proofer, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof2')
      create(:eby_def_event, user: proofer, eby_def: eby_def, old_status: 'NeedProof2', new_status: 'NeedProof3')
      create(:eby_def_event, user: proofer, eby_def: eby_def, old_status: 'NeedProof3', new_status: 'NeedPublish')

      # Publishing
      publisher = create(:eby_user, :publisher)
      create(:eby_def_event, user: publisher, eby_def: eby_def, old_status: 'NeedPublish', new_status: 'Published')

      events = eby_def.events.order(:created_at)
      expect(events.count).to eq(6)
      expect(events.last.new_status).to eq('Published')
    end
  end

  describe 'detecting proofer self-proofing' do
    let(:typist) { create(:eby_user, :typist) }
    let(:eby_def) { create(:eby_def) }

    it 'can identify if user has worked on definition before' do
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')

      # Check if typist has events for this def
      has_worked_on_it = EbyDefEvent.exists?(thedef: eby_def.id, who: typist.id)
      expect(has_worked_on_it).to be true
    end

    it 'can identify if user has NOT worked on definition' do
      other_user = create(:eby_user, :proofer)
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')

      has_worked_on_it = EbyDefEvent.exists?(thedef: eby_def.id, who: other_user.id)
      expect(has_worked_on_it).to be false
    end

    it 'can filter events by status transition' do
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      create(:eby_def_event, user: typist, eby_def: eby_def, old_status: 'NeedProof1', new_status: 'NeedProof2')

      typing_events = EbyDefEvent.where(thedef: eby_def.id, old_status: 'NeedTyping')
      expect(typing_events.count).to eq(1)

      proof_events = EbyDefEvent.where(thedef: eby_def.id).where("new_status LIKE 'NeedProof%'")
      expect(proof_events.count).to eq(2)
    end
  end

  describe 'validation edge cases' do
    let(:user) { create(:eby_user) }
    let(:eby_def) { create(:eby_def) }

    it 'accepts same status in old and new (abandon scenario)' do
      event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedTyping')
      expect(event).to be_valid
    end

    it 'accepts none to none transition' do
      event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'none', new_status: 'none')
      expect(event).to be_valid
    end

    it 'rejects status with extra whitespace' do
      event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'NeedTyping ', new_status: 'NeedProof1')
      expect(event).not_to be_valid
    end

    it 'rejects status with special characters' do
      event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: 'Need-Typing', new_status: 'NeedProof1')
      expect(event).not_to be_valid
      expect(event.errors[:base]).to include("'Need-Typing' is not a valid status")
    end

    it 'handles very long invalid status strings' do
      long_status = 'A' * 1000
      event = build(:eby_def_event, user: user, eby_def: eby_def, old_status: long_status, new_status: 'NeedTyping')
      expect(event).not_to be_valid
      expect(event.errors[:base].first).to include(long_status)
    end
  end

  describe 'required associations' do
    let(:user) { create(:eby_user) }
    let(:eby_def) { create(:eby_def) }

    it 'requires user association for creation' do
      event = build(:eby_def_event, user: nil, eby_def: eby_def, old_status: 'NeedTyping', new_status: 'NeedProof1')
      event.who = nil

      # Validation should fail, though database constraint behavior varies by adapter
      expect(event).not_to be_valid
    end

    it 'requires eby_def association for creation' do
      event = build(:eby_def_event, user: user, eby_def: nil, old_status: 'NeedTyping', new_status: 'NeedProof1')
      event.thedef = nil

      # Validation should fail, though database constraint behavior varies by adapter
      expect(event).not_to be_valid
    end

    it 'validates user presence through association' do
      event = EbyDefEvent.new(thedef: eby_def.id, old_status: 'NeedTyping', new_status: 'NeedProof1')
      expect(event.valid?).to be false
    end

    it 'validates eby_def presence through association' do
      event = EbyDefEvent.new(who: user.id, old_status: 'NeedTyping', new_status: 'NeedProof1')
      expect(event.valid?).to be false
    end
  end
end
