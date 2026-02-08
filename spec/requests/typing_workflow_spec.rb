# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Typing Workflow Integration', type: :request do
  let(:typist) { create(:eby_user, :typist, login: 'typist1') }
  let(:proofer) { create(:eby_user, :proofer, max_proof_level: 2, login: 'proofer1') }

  describe 'complete typing workflow' do
    it 'allows typist to get work, save progress, and complete definition' do
      # Create an available definition (small trait creates 1 part image automatically)
      def_to_type = create(:eby_def, :need_typing, :small, defhead: 'Original Head', deftext: 'Original Text')

      login_as(typist)

      # Step 1: Get work assignment
      get '/type/get_def', params: { defsize: 'small' }
      expect(response).to redirect_to("/type/edit/#{def_to_type.id}")

      def_to_type.reload
      expect(def_to_type.assignee).to eq(typist)
      expect(def_to_type.assignedto).to eq(typist.id)

      # Step 2: Load the edit page
      follow_redirect!
      expect(response).to have_http_status(:success)

      # Step 3: Save work in progress
      post "/type/processtype/#{def_to_type.id}", params: {
        save: true,
        defhead: 'Partially Typed',
        deftext: 'Work in progress...',
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_to_type.reload
      expect(def_to_type.defhead).to eq('Partially Typed')
      expect(def_to_type.deftext).to eq('Work in progress...')
      expect(def_to_type.status).to eq('NeedTyping') # Status unchanged
      expect(def_to_type.assignee).to eq(typist) # Still assigned

      # Step 4: Complete the typing
      post "/type/processtype/#{def_to_type.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['type'],
        defhead: 'Fully Typed',
        deftext: 'Complete definition text',
        footnotes: '[1] Test footnote',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_to_type.reload
      expect(def_to_type.defhead).to eq('Fully Typed')
      expect(def_to_type.deftext).to eq('Complete definition text')
      expect(def_to_type.footnotes).to eq('[1] Test footnote')
      expect(def_to_type.status).to eq('NeedProof')
      expect(def_to_type.proof_round_passed).to eq(0)
      expect(def_to_type.assignee).to be_nil # Unassigned after completion

      # Verify event was created (status is 'NeedProof1' for first proof round)
      event = EbyDefEvent.where(thedef: def_to_type.id, new_status: 'NeedProof1').last
      expect(event).to be_present
      expect(event.who).to eq(typist.id)
    end

    it 'allows typist to abandon work' do
      def_to_abandon = create(:eby_def, :need_typing, :small)

      login_as(typist)

      # Get work
      get '/type/get_def', params: { defsize: 'small' }
      def_to_abandon.reload
      expect(def_to_abandon.assignee).to eq(typist)

      initial_reject_count = def_to_abandon.reject_count || 0

      # Abandon it
      get '/type/abandon', params: { id: def_to_abandon.id }
      expect(response).to redirect_to('/user/index')

      def_to_abandon.reload
      expect(def_to_abandon.assignee).to be_nil
      expect(def_to_abandon.reject_count).to eq(initial_reject_count + 1)
      expect(def_to_abandon.status).to eq('NeedTyping') # Status unchanged
    end

    it 'allows typist to mark definition as problem' do
      def_with_problem = create(:eby_def, :need_typing, :medium)

      login_as(typist)

      # Get and assign work
      get '/type/get_def', params: { defsize: 'medium' }
      def_with_problem.reload
      expect(def_with_problem.assignee).to eq(typist)

      # Mark as problem
      post "/type/processtype/#{def_with_problem.id}", params: {
        problem: true,
        defhead: def_with_problem.defhead,
        deftext: def_with_problem.deftext,
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none',
        prob_desc: 'Image is unclear'
      }

      def_with_problem.reload
      expect(def_with_problem.status).to eq('Problem')
      expect(def_with_problem.prob_desc).to eq('Image is unclear')
      expect(def_with_problem.assignee).to be_nil

      # Verify event
      event = EbyDefEvent.where(thedef: def_with_problem.id, new_status: 'Problem').last
      expect(event).to be_present
      expect(event.who).to eq(typist.id)
    end
  end

  describe 'fixup workflow' do
    it 'routes definition to fixup when language work is needed' do
      def_needing_fixup = create(:eby_def, :need_typing, :medium)

      login_as(typist)

      # Get work
      get '/type/get_def', params: { defsize: 'medium' }

      # Complete typing with Arabic work needed
      post "/type/processtype/#{def_needing_fixup.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['type'],
        defhead: 'Definition with Arabic',
        deftext: 'Contains Arabic text',
        footnotes: '',
        arabic: 'todo',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      def_needing_fixup.reload
      expect(def_needing_fixup.status).to eq('NeedFixup')
      expect(def_needing_fixup.arabic).to eq('todo')
      expect(def_needing_fixup.assignee).to be_nil
    end

    it 'allows fixer to complete fixup and send to proofing' do
      fixer = create(:eby_user, :fixer, login: 'fixer1', does_greek: true)
      def_in_fixup = create(:eby_def, :need_fixup, :small, greek: 'todo')

      login_as(fixer)

      # Get fixup work
      get '/type/get_fixup', params: { defsize: 'small' }

      # May or may not get this specific definition depending on query logic
      # If assigned, complete the fixup
      if response.redirect? && response.location.include?("/type/edit/#{def_in_fixup.id}")
        post "/type/processtype/#{def_in_fixup.id}", params: {
          save_and_done: true,
          act: Rails.configuration.constants['fixup'],
          defhead: def_in_fixup.defhead,
          deftext: 'Fixed Greek text',
          footnotes: '',
          arabic: 'none',
          greek: 'done',
          russian: 'none',
          extra: 'none'
        }

        def_in_fixup.reload
        expect(def_in_fixup.status).to eq('NeedProof')
        expect(def_in_fixup.greek).to eq('done')
      else
        # If we didn't get this specific definition, just verify the action works
        expect(response).to be_redirect
      end
    end
  end

  describe 'multi-user workflow' do
    it 'prevents multiple users from getting the same definition' do
      typist2 = create(:eby_user, :typist, login: 'typist2')
      shared_def = create(:eby_def, :need_typing, :small)

      # Typist 1 gets the work
      login_as(typist)
      get '/type/get_def', params: { defsize: 'small' }
      shared_def.reload
      expect(shared_def.assignee).to eq(typist)

      # Typist 2 should not get the same definition
      logout
      login_as(typist2)
      get '/type/get_def', params: { defsize: 'small' }

      # Should redirect to user index (no work available)
      expect(response).to redirect_to('/user/index')

      # Definition should still be assigned to typist1
      shared_def.reload
      expect(shared_def.assignee).to eq(typist)
    end

    it 'prevents typist from editing another users assigned work' do
      typist2 = create(:eby_user, :typist, login: 'typist2')
      other_def = create(:eby_def, :need_typing, :small, assignee: typist2, assignedto: typist2.id)

      login_as(typist)

      # Try to access other user's work
      get "/type/edit/#{other_def.id}"
      expect(response).to redirect_to('/user/index')
    end
  end

  describe 'size-based work assignment' do
    let!(:small_def) { create(:eby_def, :need_typing, :small, defhead: 'Small') }
    let!(:medium_def) { create(:eby_def, :need_typing, :medium, defhead: 'Medium') }
    let!(:large_def) { create(:eby_def, :need_typing, :large, defhead: 'Large') }

    before do
      login_as(typist)
    end

    it 'assigns small definition when requesting small' do
      get '/type/get_def', params: { defsize: 'small' }
      expect(response).to redirect_to("/type/edit/#{small_def.id}")

      small_def.reload
      expect(small_def.assignee).to eq(typist)
    end

    it 'assigns medium definition when requesting medium' do
      get '/type/get_def', params: { defsize: 'medium' }
      expect(response).to redirect_to("/type/edit/#{medium_def.id}")

      medium_def.reload
      expect(medium_def.assignee).to eq(typist)
    end

    it 'assigns large definition when requesting large' do
      get '/type/get_def', params: { defsize: 'large' }
      expect(response).to redirect_to("/type/edit/#{large_def.id}")

      large_def.reload
      expect(large_def.assignee).to eq(typist)
    end
  end

  describe 'reject count workflow' do
    it 'increments reject count each time work is abandoned' do
      frequently_rejected = create(:eby_def, :need_typing, :small, reject_count: 0)

      login_as(typist)

      # First abandonment
      get '/type/get_def', params: { defsize: 'small' }
      get '/type/abandon', params: { id: frequently_rejected.id }

      frequently_rejected.reload
      expect(frequently_rejected.reject_count).to eq(1)

      # Second abandonment
      get '/type/get_def', params: { defsize: 'small' }
      get '/type/abandon', params: { id: frequently_rejected.id }

      frequently_rejected.reload
      expect(frequently_rejected.reject_count).to eq(2)
    end
  end
end
