# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyDefPartImage, type: :model do
  describe 'associations' do
    it { should belong_to(:eby_def).with_foreign_key('thedef').optional }
    it { should belong_to(:colimg).class_name('EbyColumnImage').with_foreign_key('coldefimg_id') }
  end

  describe 'validations' do
    let(:col) { create(:eby_column_image) }
    subject { build(:eby_def_part_image, colimg: col) }

    it { should validate_presence_of(:colimg) }
    it { should validate_numericality_of(:defno).allow_nil }
    it { should validate_numericality_of(:partnum).allow_nil }
    it { should validate_inclusion_of(:is_last).in_array([true, false]).allow_nil }
  end

  describe 'ActiveStorage attachment' do
    it 'has cloud_defpartjpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_defpartjpeg)
    end

    it 'can attach definition part image' do
      part = create(:eby_def_part_image)
      expect(part.cloud_defpartjpeg).to be_attached
    end
  end

  describe 'basic attributes' do
    it 'stores defno (definition number in column)' do
      part = create(:eby_def_part_image, defno: 5)
      expect(part.defno).to eq(5)
    end

    it 'stores partnum (part number within definition)' do
      part = create(:eby_def_part_image, partnum: 2)
      expect(part.partnum).to eq(2)
    end

    it 'stores filename' do
      part = create(:eby_def_part_image, filename: 'def_part_001.jpg')
      expect(part.filename).to eq('def_part_001.jpg')
    end

    it 'tracks if this is the last part' do
      part = create(:eby_def_part_image, is_last: true)
      expect(part.is_last).to be true
    end
  end

  describe 'is_last flag' do
    it 'marks last part of multi-part definition' do
      eby_def = create(:eby_def)
      col = create(:eby_column_image)

      part1 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 1, is_last: false)
      part2 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 2, is_last: false)
      part3 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 3, is_last: true)

      expect(part1.is_last).to be false
      expect(part2.is_last).to be false
      expect(part3.is_last).to be true
    end

    it 'marks single-part definition as last' do
      part = create(:eby_def_part_image, :last_part)
      expect(part.is_last).to be true
    end
  end

  describe 'orphan parts' do
    it 'can exist without a definition (orphan)' do
      orphan = create(:eby_def_part_image, :orphan)
      expect(orphan.eby_def).to be_nil
      expect(orphan.thedef).to be_nil
      expect(orphan).to be_valid
    end

    it 'is valid without eby_def association' do
      col = create(:eby_column_image)
      orphan = build(:eby_def_part_image, eby_def: nil, colimg: col)
      expect(orphan).to be_valid
    end

    it 'can be later assigned to a definition' do
      orphan = create(:eby_def_part_image, :orphan)
      eby_def = create(:eby_def)

      orphan.update(eby_def: eby_def)
      expect(orphan.reload.eby_def).to eq(eby_def)
    end
  end

  describe '#get_part_image' do
    it 'returns cloud_defpartjpeg when attached' do
      part = create(:eby_def_part_image)
      expect(part.cloud_defpartjpeg).to be_attached
      expect(part.get_part_image).to eq(part.cloud_defpartjpeg)
    end

    it 'falls back to column image when defpartjpeg not attached' do
      col = create(:eby_column_image)
      part = EbyDefPartImage.new(colimg: col)

      expect(part.cloud_defpartjpeg).not_to be_attached
      expect(part.get_part_image).to eq(col.get_coldefjpeg)
    end

    it 'uses coldefjpeg from parent column as fallback' do
      col = create(:eby_column_image, :need_def_partition)
      part = EbyDefPartImage.new(colimg: col)

      # Should get the column's def image
      expect(part.get_part_image).to eq(col.cloud_coldefjpeg)
    end

    it 'uses coljpeg as final fallback' do
      col = create(:eby_column_image)
      part = EbyDefPartImage.new(colimg: col)

      # Should fall back to the full column image
      expect(part.get_part_image).to eq(col.cloud_coljpeg)
    end
  end

  describe 'multi-part definitions' do
    it 'creates definition with multiple parts' do
      eby_def = create(:eby_def)
      col = create(:eby_column_image)

      part1 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 1)
      part2 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 2)
      part3 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 3)

      expect(eby_def.part_images.count).to eq(3)
      expect(eby_def.part_images).to include(part1, part2, part3)
    end

    it 'orders parts by partnum' do
      eby_def = create(:eby_def)
      col = create(:eby_column_image)

      part3 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 3)
      part1 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 1)
      part2 = create(:eby_def_part_image, eby_def: eby_def, colimg: col, partnum: 2)

      parts = eby_def.part_images.order(:partnum)
      expect(parts.pluck(:partnum)).to eq([1, 2, 3])
    end
  end

  describe 'cross-column definitions' do
    it 'allows definition parts across multiple columns' do
      eby_def = create(:eby_def)
      scan = create(:eby_scan_image)
      col1 = create(:eby_column_image, scan: scan, colnum: 1)
      col2 = create(:eby_column_image, scan: scan, colnum: 2)

      part1 = create(:eby_def_part_image, eby_def: eby_def, colimg: col1, partnum: 1, is_last: false)
      part2 = create(:eby_def_part_image, eby_def: eby_def, colimg: col2, partnum: 2, is_last: true)

      expect(eby_def.part_images.count).to eq(2)
      expect(part1.colimg).not_to eq(part2.colimg)
    end
  end

  describe 'defno ordering' do
    it 'tracks order of definitions within column' do
      col = create(:eby_column_image)

      def1 = create(:eby_def)
      def2 = create(:eby_def)
      def3 = create(:eby_def)

      part1 = create(:eby_def_part_image, eby_def: def1, colimg: col, defno: 0)
      part2 = create(:eby_def_part_image, eby_def: def2, colimg: col, defno: 1)
      part3 = create(:eby_def_part_image, eby_def: def3, colimg: col, defno: 2)

      expect(part1.defno).to eq(0)
      expect(part2.defno).to eq(1)
      expect(part3.defno).to eq(2)
    end

    it 'allows defno to be nil for orphans' do
      orphan = create(:eby_def_part_image, :orphan, defno: nil)
      expect(orphan.defno).to be_nil
      expect(orphan).to be_valid
    end
  end

  describe 'partnum tracking' do
    it 'allows nil partnum' do
      part = build(:eby_def_part_image, partnum: nil)
      expect(part).to be_valid
    end

    it 'starts from 1 for first part' do
      part = create(:eby_def_part_image, partnum: 1)
      expect(part.partnum).to eq(1)
    end

    it 'increments for subsequent parts' do
      eby_def = create(:eby_def, :medium)
      parts = eby_def.part_images.order(:partnum)
      expect(parts.first.partnum).to eq(1)
      expect(parts.last.partnum).to eq(2)
    end
  end

  describe 'filename storage' do
    it 'can store filename separately from attachment' do
      part = create(:eby_def_part_image, filename: 'custom_name.jpg')
      expect(part.filename).to eq('custom_name.jpg')
    end

    it 'allows nil filename' do
      part = create(:eby_def_part_image, filename: nil)
      expect(part.filename).to be_nil
    end
  end

  describe 'parent column relationship' do
    it 'requires column association' do
      part = build(:eby_def_part_image, colimg: nil)
      expect(part).not_to be_valid
    end

    it 'can access parent column' do
      col = create(:eby_column_image)
      part = create(:eby_def_part_image, colimg: col)
      expect(part.colimg).to eq(col)
    end

    it 'can access parent scan through column' do
      scan = create(:eby_scan_image)
      col = create(:eby_column_image, scan: scan)
      part = create(:eby_def_part_image, colimg: col)

      expect(part.colimg.scan).to eq(scan)
    end
  end

  describe 'deletion behavior' do
    it 'can be deleted without affecting definition' do
      eby_def = create(:eby_def)
      part = create(:eby_def_part_image, eby_def: eby_def)

      expect { part.destroy }.not_to change { EbyDef.exists?(eby_def.id) }
    end

    it 'can be deleted without affecting column' do
      col = create(:eby_column_image)
      part = create(:eby_def_part_image, colimg: col)

      expect { part.destroy }.not_to change { EbyColumnImage.exists?(col.id) }
    end
  end
end
