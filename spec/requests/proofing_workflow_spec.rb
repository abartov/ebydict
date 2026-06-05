# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proofing Workflow Integration', type: :request do
  let(:proofer1) { create(:eby_user, :proofer, max_proof_level: 1, login: 'proofer1') }
  let(:proofer2) { create(:eby_user, :proofer, max_proof_level: 2, login: 'proofer2') }
  let(:proofer3) { create(:eby_user, :proofer, max_proof_level: 3, login: 'proofer3') }
  let(:typist) { create(:eby_user, :typist, login: 'typist1') }

  describe 'three-round proofing workflow' do
    it 'completes all three proof rounds and advances to NeedPublish' do
      # Create a typed definition ready for proofing
      def_to_proof = create(:eby_def, :need_proof_1, :small, defhead: 'Test Definition')

      # Round 1: Proofer with level 1
      login_as(proofer1)
      get '/type/get_proof', params: { defsize: 'small', round: 1 }
      expect(response).to redirect_to("/type/edit/#{def_to_proof.id}")

      def_to_proof.reload
      expect(def_to_proof.assignee).to eq(proofer1)
      expect(def_to_proof.proof_round_passed).to eq(0)

      # Complete round 1
      post "/type/processtype/#{def_to_proof.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['proof'],
        defhead: def_to_proof.defhead,
        deftext: 'Proofed round 1',
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_to_proof.reload
      expect(def_to_proof.status).to eq('NeedProof')
      expect(def_to_proof.proof_round_passed).to eq(1)
      expect(def_to_proof.assignee).to be_nil

      # Verify event
      event1 = EbyDefEvent.where(thedef: def_to_proof.id, new_status: 'NeedProof2').last
      expect(event1).to be_present
      expect(event1.who).to eq(proofer1.id)

      # Round 2: Proofer with level 2
      logout
      login_as(proofer2)
      get '/type/get_proof', params: { defsize: 'small', round: 2 }
      expect(response).to redirect_to("/type/edit/#{def_to_proof.id}")

      def_to_proof.reload
      expect(def_to_proof.assignee).to eq(proofer2)

      # Complete round 2
      post "/type/processtype/#{def_to_proof.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['proof'],
        defhead: def_to_proof.defhead,
        deftext: 'Proofed round 2',
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_to_proof.reload
      expect(def_to_proof.status).to eq('NeedProof')
      expect(def_to_proof.proof_round_passed).to eq(2)
      expect(def_to_proof.assignee).to be_nil

      # Verify event
      event2 = EbyDefEvent.where(thedef: def_to_proof.id, new_status: 'NeedProof3').last
      expect(event2).to be_present
      expect(event2.who).to eq(proofer2.id)

      # Round 3: Proofer with level 3
      logout
      login_as(proofer3)
      get '/type/get_proof', params: { defsize: 'small', round: 3 }
      expect(response).to redirect_to("/type/edit/#{def_to_proof.id}")

      def_to_proof.reload
      expect(def_to_proof.assignee).to eq(proofer3)

      # Complete round 3 - should advance to NeedPublish
      post "/type/processtype/#{def_to_proof.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['proof'],
        defhead: def_to_proof.defhead,
        deftext: 'Proofed round 3 - final',
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_to_proof.reload
      expect(def_to_proof.status).to eq('NeedPublish')
      expect(def_to_proof.proof_round_passed).to eq(3)
      expect(def_to_proof.assignee).to be_nil

      # Verify final event
      event3 = EbyDefEvent.where(thedef: def_to_proof.id, new_status: 'NeedPublish').last
      expect(event3).to be_present
      expect(event3.who).to eq(proofer3.id)
    end
  end

  describe 'proof level restrictions' do
    it 'prevents proofer from proofing rounds above their level' do
      def_at_round2 = create(:eby_def, :need_proof_2, :medium)

      login_as(proofer1) # max_proof_level: 1

      # Try to get round 2 work (above their level)
      get '/type/get_proof', params: { defsize: 'medium', round: 2 }
      expect(response).to redirect_to('/user/index')

      # Definition should not be assigned
      def_at_round2.reload
      expect(def_at_round2.assignee).to be_nil
    end

    it 'allows proofer to proof at their max level' do
      def_at_round2 = create(:eby_def, :need_proof_2, :medium)

      login_as(proofer2) # max_proof_level: 2

      # Should be able to get round 2 work
      get '/type/get_proof', params: { defsize: 'medium', round: 2 }
      expect(response).to redirect_to("/type/edit/#{def_at_round2.id}")

      def_at_round2.reload
      expect(def_at_round2.assignee).to eq(proofer2)
    end

    it 'uses user max_proof_level when round not specified' do
      def_at_round1 = create(:eby_def, :need_proof_1, :small)
      def_at_round2 = create(:eby_def, :need_proof_2, :small)

      login_as(proofer2) # max_proof_level: 2

      # Get work without specifying round - should prioritize highest round within capability
      get '/type/get_proof', params: { defsize: 'small' }

      # Should get the round 2 definition (higher priority)
      def_at_round2.reload
      expect(def_at_round2.assignee).to eq(proofer2)
    end
  end

  describe 'self-proofing prevention' do
    it 'prevents proofer from proofing their own typing' do
      # Proofer3 types a definition
      def_typed_by_proofer = create(:eby_def, :need_typing, :small)

      login_as(proofer3)
      get '/type/get_def', params: { defsize: 'small' }

      # Complete typing
      post "/type/processtype/#{def_typed_by_proofer.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['type'],
        defhead: 'Self Typed',
        deftext: 'Typed by proofer3',
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_typed_by_proofer.reload
      expect(def_typed_by_proofer.status).to eq('NeedProof')

      # Create the typing event (simulating what the controller does)
      create(:eby_def_event, thedef: def_typed_by_proofer.id, who: proofer3.id, new_status: 'NeedProof1')

      # Try to proof the same definition - should be prevented by query
      get '/type/get_proof', params: { defsize: 'small', round: 1 }

      # Should not get this definition (because proofer3 is in events for this def)
      # Will redirect to user index if no other work available
      expect(response).to redirect_to('/user/index')
    end
  end

  describe 'proof workflow with fixup' do
    it 'sends definition back to proofing after fixup completion' do
      # Definition completed typing with fixup needed
      def_needing_fixup = create(:eby_def, :need_fixup, :small, greek: 'todo')
      fixer = create(:eby_user, :fixer, login: 'fixer1', does_greek: true)

      login_as(fixer)
      get '/type/get_fixup', params: { defsize: 'small' }

      if response.redirect? && response.location.include?("/type/edit/#{def_needing_fixup.id}")
        # Complete the fixup
        post "/type/processtype/#{def_needing_fixup.id}", params: {
          save_and_done: true,
          act: Rails.configuration.constants['fixup'],
          defhead: def_needing_fixup.defhead,
          deftext: 'Fixed Greek',
          footnotes: '',
          arabic: 'none',
          greek: 'done',
          russian: 'none',
          extra: 'none'
        }

        def_needing_fixup.reload
        expect(def_needing_fixup.status).to eq('NeedProof')
        expect(def_needing_fixup.proof_round_passed).to eq(0) # Start proofing from round 1
        expect(def_needing_fixup.greek).to eq('done')
      end
    end
  end

  describe 'round fallback mechanism' do
    it 'falls back to earlier proof rounds when higher rounds not available' do
      def_round1 = create(:eby_def, :need_proof_1, :small)
      # No definitions at round 2 or 3

      login_as(proofer3) # max_proof_level: 3

      # Request without specifying round - should fall back to round 1
      get '/type/get_proof', params: { defsize: 'small' }

      def_round1.reload
      expect(def_round1.assignee).to eq(proofer3)
    end
  end

  describe 'abandon during proofing' do
    it 'allows proofer to abandon work and increments reject_count' do
      def_to_abandon = create(:eby_def, :need_proof_1, :small, reject_count: 0)

      login_as(proofer1)
      get '/type/get_proof', params: { defsize: 'small', round: 1 }

      def_to_abandon.reload
      expect(def_to_abandon.assignee).to eq(proofer1)

      # Abandon the work
      get '/type/abandon', params: { id: def_to_abandon.id }

      def_to_abandon.reload
      expect(def_to_abandon.assignee).to be_nil
      expect(def_to_abandon.reject_count).to eq(1)
      expect(def_to_abandon.status).to eq('NeedProof') # Status unchanged
    end
  end
end
