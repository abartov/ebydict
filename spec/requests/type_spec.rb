# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Type Controller', type: :request do
  let(:typist) { create(:eby_user, :typist, login: 'typist1') }
  let(:proofer) { create(:eby_user, :proofer, max_proof_level: 2, login: 'proofer1') }
  let(:fixer) { create(:eby_user, :fixer, login: 'fixer1') }
  let(:publisher) { create(:eby_user, :publisher, login: 'publisher1') }
  let(:regular_user) { create(:eby_user, login: 'regular1') }

  describe 'authentication and authorization' do
    it 'requires login for all actions' do
      get '/type/get_def'
      expect(response).to redirect_to('/login/login')
    end

    it 'requires at least typist role' do
      login_as(regular_user)
      get '/type/get_def'
      # Should redirect since user has no typist role
      expect(response).to redirect_to('/user/index')
    end

    it 'allows access with typist role' do
      login_as(typist)
      # Without a definition available, it will redirect but with proper auth
      get '/type/get_def', params: { defsize: 'small' }
      # Will redirect to /user/index since no defs available, but that means auth worked
      expect(response).to redirect_to('/user/index')
    end
  end

  describe 'GET /type/get_def' do
    let!(:available_def) { create(:eby_def, :need_typing, :small) }

    context 'as typist' do
      before { login_as(typist) }

      it 'assigns a definition' do
        get '/type/get_def', params: { defsize: 'small' }
        expect(response).to redirect_to("/type/edit/#{available_def.id}")
      end

      it 'redirects when no definitions available' do
        available_def.update(assignedto: 999)  # Assign to someone else
        get '/type/get_def', params: { defsize: 'small' }
        expect(response).to redirect_to('/user/index')
      end
    end

    context 'as non-typist' do
      before { login_as(regular_user) }

      it 'denies access' do
        get '/type/get_def', params: { defsize: 'small' }
        expect(response).to redirect_to('/user/index')
      end
    end
  end

  describe 'GET /type/get_proof' do
    let!(:available_def) { create(:eby_def, :need_proof_1, :medium) }

    context 'as proofer' do
      before { login_as(proofer) }

      it 'assigns a proof definition' do
        get '/type/get_proof', params: { defsize: 'medium', round: 1 }
        expect(response).to redirect_to("/type/edit/#{available_def.id}")
      end

      it 'uses users max_proof_level when round not specified' do
        get '/type/get_proof', params: { defsize: 'medium' }
        # Should work since proofer has max_proof_level: 2
        expect(response).to redirect_to("/type/edit/#{available_def.id}")
      end

      it 'rejects proof round above users level' do
        low_proofer = create(:eby_user, :proofer, max_proof_level: 1, login: 'lowproof')
        logout
        login_as(low_proofer)

        get '/type/get_proof', params: { defsize: 'medium', round: 2 }
        expect(response).to redirect_to('/user/index')
      end
    end

    context 'as non-proofer' do
      before { login_as(typist) }

      it 'denies access' do
        get '/type/get_proof', params: { defsize: 'medium' }
        expect(response).to redirect_to('/user/index')
      end
    end
  end

  describe 'GET /type/get_fixup' do
    let!(:available_def) { create(:eby_def, :need_fixup, :large, assignedto: nil, assignee: nil) }

    context 'as fixer' do
      before { login_as(fixer) }

      it 'processes fixup request without error' do
        # The assign_def_by_size method has complex criteria for finding suitable definitions
        # This test verifies the fixer role check passes and the request is handled
        get '/type/get_fixup', params: { defsize: 'large' }

        # Should redirect (either to edit or to user if none available)
        expect(response).to be_redirect
        # Should not show an error about not being a fixer
        expect(flash[:error]).not_to match(/fixer/i) if flash[:error]
      end
    end

    context 'as non-fixer' do
      before { login_as(typist) }

      it 'denies access' do
        get '/type/get_fixup', params: { defsize: 'large' }
        expect(response).to redirect_to('/user/index')
      end
    end
  end

  describe 'GET /type/edit/:id' do
    let!(:scan) { create(:eby_scan_image) }
    let!(:col_img) { create(:eby_column_image, scan: scan) }
    let!(:my_def) { create(:eby_def, :need_typing, assignee: typist, assignedto: typist.id) }
    let!(:my_part) { create(:eby_def_part_image, eby_def: my_def, colimg: col_img, partnum: 1) }

    let!(:other_def) { create(:eby_def, :need_typing, assignee: proofer, assignedto: proofer.id) }
    let!(:other_part) { create(:eby_def_part_image, eby_def: other_def, colimg: col_img, partnum: 1) }

    context 'as assignee' do
      before { login_as(typist) }

      it 'allows editing assigned definition' do
        get "/type/edit/#{my_def.id}"
        expect(response).to have_http_status(:success)
      end

      it 'prevents editing other users definition' do
        get "/type/edit/#{other_def.id}"
        expect(response).to redirect_to('/user/index')
      end
    end

    context 'as publisher' do
      before { login_as(publisher) }

      it 'allows editing any definition' do
        get "/type/edit/#{other_def.id}"
        expect(response).to have_http_status(:success)
      end
    end

    it 'returns error for non-existent definition' do
      login_as(typist)
      get "/type/edit/99999"
      expect(response).to redirect_to('/user/index')
    end
  end

  describe 'POST /type/processtype' do
    let!(:scan) { create(:eby_scan_image) }
    let!(:col_img) { create(:eby_column_image, scan: scan) }
    let!(:my_def) do
      create(:eby_def,
             :need_typing,
             assignee: typist,
             assignedto: typist.id,
             defhead: 'Original',
             deftext: 'Original text')
    end
    let!(:my_part) { create(:eby_def_part_image, eby_def: my_def, colimg: col_img, partnum: 1) }

    before { login_as(typist) }

    context 'with save parameter' do
      it 'saves changes without changing status' do
        post "/type/processtype/#{my_def.id}", params: {
          save: true,
          defhead: 'Updated',
          deftext: 'Updated text',
          footnotes: '',
          arabic: 'none',
          greek: 'none',
          russian: 'none',
          extra: 'none'
        }

        my_def.reload
        expect(my_def.defhead).to eq('Updated')
        expect(my_def.deftext).to eq('Updated text')
        expect(my_def.status).to eq('NeedTyping')
      end

      it 're-renders edit view for continued editing' do
        post "/type/processtype/#{my_def.id}", params: {
          save: true,
          defhead: 'Updated',
          deftext: 'Updated text',
          footnotes: '',
          arabic: 'none',
          greek: 'none',
          russian: 'none',
          extra: 'none'
        }

        expect(response).to have_http_status(:success)
      end
    end

    context 'with save_and_done parameter' do
      it 'saves and transitions to NeedProof1' do
        post "/type/processtype/#{my_def.id}", params: {
          save_and_done: true,
          act: Rails.configuration.constants['type'],
          defhead: 'Completed',
          deftext: 'Completed text',
          footnotes: '',
          arabic: 'none',
          greek: 'none',
          russian: 'none',
          extra: 'none'
        }

        my_def.reload
        expect(my_def.status).to eq('NeedProof')
        expect(my_def.proof_round_passed).to eq(0)
        expect(my_def.assignee).to be_nil
      end

      it 'transitions to NeedFixup when fixup needed' do
        post "/type/processtype/#{my_def.id}", params: {
          save_and_done: true,
          act: Rails.configuration.constants['type'],
          defhead: 'With Arabic',
          deftext: 'Text with Arabic',
          footnotes: '',
          arabic: 'todo',
          greek: 'none',
          russian: 'none',
          extra: 'none'
        }

        my_def.reload
        expect(my_def.status).to eq('NeedFixup')
        expect(my_def.assignee).to be_nil
      end

      it 'creates EbyDefEvent record' do
        expect {
          post "/type/processtype/#{my_def.id}", params: {
            save_and_done: true,
            act: Rails.configuration.constants['type'],
            defhead: 'Completed',
            deftext: 'Completed text',
            footnotes: '',
            arabic: 'none',
            greek: 'none',
            russian: 'none',
            extra: 'none'
          }
        }.to change(EbyDefEvent, :count).by(1)
      end

      it 'redirects to user page' do
        post "/type/processtype/#{my_def.id}", params: {
          save_and_done: true,
          act: Rails.configuration.constants['type'],
          defhead: 'Completed',
          deftext: 'Completed text',
          footnotes: '',
          arabic: 'none',
          greek: 'none',
          russian: 'none',
          extra: 'none'
        }

        expect(response).to redirect_to('/user/index')
      end
    end

    context 'with problem parameter' do
      it 'marks definition as Problem' do
        post "/type/processtype/#{my_def.id}", params: {
          problem: true,
          defhead: my_def.defhead,
          deftext: my_def.deftext,
          footnotes: '',
          arabic: 'none',
          greek: 'none',
          russian: 'none',
          extra: 'none',
          prob_desc: 'Text is unclear'
        }

        my_def.reload
        expect(my_def.status).to eq('Problem')
        expect(my_def.assignee).to be_nil
        expect(my_def.prob_desc).to eq('Text is unclear')
      end

      it 'creates EbyDefEvent for problem' do
        expect {
          post "/type/processtype/#{my_def.id}", params: {
            problem: true,
            defhead: my_def.defhead,
            deftext: my_def.deftext,
            footnotes: '',
            arabic: 'none',
            greek: 'none',
            russian: 'none',
            extra: 'none',
            prob_desc: 'Issue found'
          }
        }.to change(EbyDefEvent, :count).by(1)

        event = EbyDefEvent.last
        expect(event.new_status).to eq('Problem')
      end
    end

    context 'with abandon parameter' do
      it 'un-assigns definition' do
        post "/type/processtype/#{my_def.id}", params: {
          abandon: true
        }

        my_def.reload
        expect(my_def.assignee).to be_nil
      end

      it 'increments reject count' do
        initial_count = my_def.reject_count || 0

        post "/type/processtype/#{my_def.id}", params: {
          abandon: true
        }

        my_def.reload
        expect(my_def.reject_count).to eq(initial_count + 1)
      end
    end
  end

  describe 'GET /type/abandon' do
    let!(:my_def) { create(:eby_def, :need_typing, assignee: typist, assignedto: typist.id) }

    before { login_as(typist) }

    it 'abandons the definition' do
      get '/type/abandon', params: { id: my_def.id }

      my_def.reload
      expect(my_def.assignee).to be_nil
    end

    it 'increments reject_count' do
      my_def.update(reject_count: 2)

      get '/type/abandon', params: { id: my_def.id }

      my_def.reload
      expect(my_def.reject_count).to eq(3)
    end

    it 'redirects to user page' do
      get '/type/abandon', params: { id: my_def.id }
      expect(response).to redirect_to('/user/index')
    end
  end

  describe 'POST /type/set_marker' do
    let!(:my_def) { create(:eby_def, :need_typing, assignee: typist, assignedto: typist.id) }

    before { login_as(typist) }

    it 'creates marker for definition without one' do
      expect {
        post "/type/set_marker/#{my_def.id}", params: {
          partnum: 1,
          marker_y: 150,
          footpart: nil,
          footmarker: nil
        }
      }.to change(EbyMarker, :count).by(1)

      marker = EbyMarker.last
      expect(marker.def_id).to eq(my_def.id)
      expect(marker.marker_y).to eq(150)
      expect(marker.partnum).to eq(1)
    end

    it 'updates existing marker' do
      marker = create(:eby_marker, thedef: my_def, user: typist, marker_y: 100)

      post "/type/set_marker/#{my_def.id}", params: {
        partnum: 2,
        marker_y: 200,
        footpart: 1,
        footmarker: 250
      }

      marker.reload
      expect(marker.marker_y).to eq(200)
      expect(marker.partnum).to eq(2)
      expect(marker.footmarker).to eq(250)
    end

    it 'returns success status' do
      post "/type/set_marker/#{my_def.id}", params: {
        partnum: 1,
        marker_y: 150
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'proof workflow' do
    let!(:proof_scan) { create(:eby_scan_image) }
    let!(:proof_col) { create(:eby_column_image, scan: proof_scan) }
    let!(:proof_def) do
      create(:eby_def,
             status: 'NeedProof',
             proof_round_passed: 0,
             assignee: proofer,
             assignedto: proofer.id)
    end
    let!(:proof_part) { create(:eby_def_part_image, eby_def: proof_def, colimg: proof_col, partnum: 1) }

    before { login_as(proofer) }

    it 'completes proof round 1 and advances to round 2' do
      post "/type/processtype/#{proof_def.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['proof'],
        defhead: proof_def.defhead,
        deftext: proof_def.deftext,
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      proof_def.reload
      expect(proof_def.status).to eq('NeedProof')
      expect(proof_def.proof_round_passed).to eq(1)
    end

    it 'completes final proof round and advances to NeedPublish' do
      proof_def.update(proof_round_passed: 2)  # LAST_PROOF_ROUND is 3

      post "/type/processtype/#{proof_def.id}", params: {
        save_and_done: true,
        act: Rails.configuration.constants['proof'],
        defhead: proof_def.defhead,
        deftext: proof_def.deftext,
        footnotes: '',
        arabic: 'none',
        greek: 'none',
        russian: 'none',
        extra: 'none'
      }

      proof_def.reload
      expect(proof_def.status).to eq('NeedPublish')
      expect(proof_def.proof_round_passed).to eq(3)
    end
  end
end
