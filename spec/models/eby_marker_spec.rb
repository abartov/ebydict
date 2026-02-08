# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyMarker, type: :model do
  describe 'associations' do
    it { should belong_to(:thedef).class_name('EbyDef').with_foreign_key('def_id') }
    it { should belong_to(:user).class_name('EbyUser').with_foreign_key('user_id') }
  end

  describe 'basic attributes' do
    it 'stores marker Y position' do
      marker = create(:eby_marker, marker_y: 150)
      expect(marker.marker_y).to eq(150)
    end

    it 'stores part number' do
      marker = create(:eby_marker, partnum: 2)
      expect(marker.partnum).to eq(2)
    end

    it 'stores footnote part number' do
      marker = create(:eby_marker, footpart: 1)
      expect(marker.footpart).to eq(1)
    end

    it 'stores footnote marker position' do
      marker = create(:eby_marker, footmarker: 75)
      expect(marker.footmarker).to eq(75)
    end
  end

  describe 'definition relationship' do
    it 'requires an associated definition' do
      marker = build(:eby_marker, thedef: nil)
      expect(marker).not_to be_valid
    end

    it 'can access parent definition' do
      eby_def = create(:eby_def, defhead: 'מילה')
      marker = create(:eby_marker, thedef: eby_def)

      expect(marker.thedef).to eq(eby_def)
      expect(marker.thedef.defhead).to eq('מילה')
    end

    it 'allows multiple markers per definition' do
      eby_def = create(:eby_def)
      marker1 = create(:eby_marker, thedef: eby_def, partnum: 1, marker_y: 100)
      marker2 = create(:eby_marker, thedef: eby_def, partnum: 2, marker_y: 200)

      markers = EbyMarker.where(def_id: eby_def.id)
      expect(markers.count).to eq(2)
    end
  end

  describe 'user relationship' do
    it 'requires an associated user' do
      marker = build(:eby_marker, user: nil)
      expect(marker).not_to be_valid
    end

    it 'tracks who placed the marker' do
      user = create(:eby_user, login: 'marker_user')
      marker = create(:eby_marker, user: user)

      expect(marker.user).to eq(user)
      expect(marker.user.login).to eq('marker_user')
    end

    it 'allows same user to place multiple markers' do
      user = create(:eby_user)
      eby_def = create(:eby_def)

      marker1 = create(:eby_marker, user: user, thedef: eby_def, marker_y: 100)
      marker2 = create(:eby_marker, user: user, thedef: eby_def, marker_y: 200)

      markers = EbyMarker.where(user_id: user.id)
      expect(markers.count).to eq(2)
    end
  end

  describe 'marker positioning' do
    it 'stores Y coordinate for definition marker' do
      marker = create(:eby_marker, marker_y: 250)
      expect(marker.marker_y).to eq(250)
    end

    it 'allows marker at top of image (y=0)' do
      marker = create(:eby_marker, marker_y: 0)
      expect(marker.marker_y).to eq(0)
    end

    it 'allows very large Y coordinates' do
      marker = create(:eby_marker, marker_y: 5000)
      expect(marker.marker_y).to eq(5000)
    end

    it 'allows negative Y coordinates' do
      # Might be used for special cases or adjustments
      marker = create(:eby_marker, marker_y: -10)
      expect(marker.marker_y).to eq(-10)
    end
  end

  describe 'part numbering' do
    it 'tracks which part of multi-part definition' do
      marker = create(:eby_marker, partnum: 3)
      expect(marker.partnum).to eq(3)
    end

    it 'allows partnum to be nil' do
      marker = create(:eby_marker, partnum: nil)
      expect(marker.partnum).to be_nil
    end

    it 'allows zero partnum' do
      marker = create(:eby_marker, partnum: 0)
      expect(marker.partnum).to eq(0)
    end

    it 'orders markers by part number' do
      eby_def = create(:eby_def)
      marker3 = create(:eby_marker, thedef: eby_def, partnum: 3)
      marker1 = create(:eby_marker, thedef: eby_def, partnum: 1)
      marker2 = create(:eby_marker, thedef: eby_def, partnum: 2)

      ordered_markers = EbyMarker.where(def_id: eby_def.id).order(:partnum)
      expect(ordered_markers.pluck(:partnum)).to eq([1, 2, 3])
    end
  end

  describe 'footnote markers' do
    it 'can mark footnote part' do
      marker = create(:eby_marker, footpart: 2)
      expect(marker.footpart).to eq(2)
    end

    it 'can mark footnote Y position' do
      marker = create(:eby_marker, footmarker: 150)
      expect(marker.footmarker).to eq(150)
    end

    it 'handles definition with both def and footnote markers' do
      marker = create(:eby_marker,
                     partnum: 1,
                     marker_y: 100,
                     footpart: 1,
                     footmarker: 300)

      expect(marker.partnum).to eq(1)
      expect(marker.marker_y).to eq(100)
      expect(marker.footpart).to eq(1)
      expect(marker.footmarker).to eq(300)
    end

    it 'allows nil footnote markers' do
      marker = create(:eby_marker, footpart: nil, footmarker: nil)

      expect(marker.footpart).to be_nil
      expect(marker.footmarker).to be_nil
    end
  end

  describe 'deletion behavior' do
    it 'can be deleted without affecting definition' do
      eby_def = create(:eby_def)
      marker = create(:eby_marker, thedef: eby_def)

      expect { marker.destroy }.not_to change { EbyDef.count }
      expect(eby_def.reload).to be_persisted
    end

    it 'can be deleted without affecting user' do
      user = create(:eby_user)
      marker = create(:eby_marker, user: user)

      expect { marker.destroy }.not_to change { EbyUser.count }
      expect(user.reload).to be_persisted
    end
  end

  describe 'use cases' do
    it 'supports manual partition correction workflow' do
      # User transcribes definition and notices partition issue
      eby_def = create(:eby_def, :need_typing)
      user = create(:eby_user, :typist)

      # User places marker to indicate correct split point
      marker = create(:eby_marker,
                     thedef: eby_def,
                     user: user,
                     partnum: 1,
                     marker_y: 175)

      expect(marker.thedef).to eq(eby_def)
      expect(marker.user).to eq(user)
      expect(marker.marker_y).to eq(175)
    end

    it 'supports multi-part definition with separate markers' do
      eby_def = create(:eby_def)
      user = create(:eby_user)

      # Mark first part
      marker1 = create(:eby_marker,
                      thedef: eby_def,
                      user: user,
                      partnum: 1,
                      marker_y: 50)

      # Mark second part
      marker2 = create(:eby_marker,
                      thedef: eby_def,
                      user: user,
                      partnum: 2,
                      marker_y: 150)

      markers = EbyMarker.where(def_id: eby_def.id).order(:partnum)
      expect(markers.map(&:marker_y)).to eq([50, 150])
    end

    it 'supports footnote separation' do
      eby_def = create(:eby_def)
      user = create(:eby_user)

      # Mark where definition ends and footnote begins
      marker = create(:eby_marker,
                     thedef: eby_def,
                     user: user,
                     marker_y: 200,      # Main definition marker
                     footmarker: 250)     # Footnote start marker

      expect(marker.marker_y).to eq(200)
      expect(marker.footmarker).to eq(250)
    end
  end

  describe 'timestamps' do
    it 'sets created_at on creation' do
      marker = create(:eby_marker)
      expect(marker.created_at).to be_present
    end

    it 'updates updated_at on modification' do
      marker = create(:eby_marker, marker_y: 100)
      original_updated_at = marker.updated_at

      sleep 0.01 # Ensure time passes
      marker.update(marker_y: 150)

      expect(marker.updated_at).to be > original_updated_at
    end
  end
end
