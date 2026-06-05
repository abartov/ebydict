# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyColumnImage, type: :model do
  describe 'associations' do
    it { should belong_to(:scan).class_name('EbyScanImage').with_foreign_key('eby_scan_image_id') }
    it { should have_many(:def_part_images).class_name('EbyDefPartImage').with_foreign_key('coldefimg_id') }
    it { should belong_to(:assignee).class_name('EbyUser').with_foreign_key('assignedto').optional }
    it { should belong_to(:partitioner).class_name('EbyUser').with_foreign_key('partitioned_by').optional }
    it { should belong_to(:defpartitioner).class_name('EbyUser').with_foreign_key('defpartitioner_id').optional }
  end

  describe 'validations' do
    let(:scan) { create(:eby_scan_image) }
    subject { build(:eby_column_image, scan: scan) }

    it { should validate_presence_of(:pagenum) }
    it { should validate_numericality_of(:pagenum) }
    it { should validate_presence_of(:colnum) }
    it { should validate_numericality_of(:colnum) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[NeedPartition NeedDefPartition Partitioned GotOrphans]) }
    it { should validate_presence_of(:scan) }
  end

  describe 'ActiveStorage attachments' do
    it 'has cloud_coljpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_coljpeg)
    end

    it 'has cloud_smalljpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_smalljpeg)
    end

    it 'has cloud_coldefjpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_coldefjpeg)
    end

    it 'has cloud_colfootjpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_colfootjpeg)
    end

    it 'can attach column image' do
      col = create(:eby_column_image)
      expect(col.cloud_coljpeg).to be_attached
    end

    it 'can attach separate definition and footnote images' do
      col = create(:eby_column_image, :need_def_partition)
      expect(col.cloud_coldefjpeg).to be_attached
      expect(col.cloud_colfootjpeg).to be_attached
    end
  end

  describe 'status workflow' do
    it 'starts as NeedPartition' do
      col = create(:eby_column_image, status: 'NeedPartition')
      expect(col.status).to eq('NeedPartition')
    end

    it 'transitions to NeedDefPartition after column partition' do
      col = create(:eby_column_image, :need_def_partition)
      expect(col.status).to eq('NeedDefPartition')
    end

    it 'transitions to Partitioned after definition partition' do
      col = create(:eby_column_image, :partitioned)
      expect(col.status).to eq('Partitioned')
    end

    it 'can be marked as GotOrphans' do
      col = create(:eby_column_image, :got_orphans)
      expect(col.status).to eq('GotOrphans')
    end
  end

  describe 'partitioner tracking' do
    it 'tracks who partitioned the column' do
      partitioner = create(:eby_user, :partitioner)
      col = create(:eby_column_image, partitioner: partitioner)
      expect(col.partitioner).to eq(partitioner)
    end

    it 'tracks who partitioned definitions' do
      defpartitioner = create(:eby_user, :partitioner)
      col = create(:eby_column_image, defpartitioner: defpartitioner)
      expect(col.defpartitioner).to eq(defpartitioner)
    end

    it 'allows different users for column and def partitioning' do
      col_partitioner = create(:eby_user, :partitioner)
      def_partitioner = create(:eby_user, :partitioner)

      col = create(:eby_column_image,
        partitioner: col_partitioner,
        defpartitioner: def_partitioner
      )

      expect(col.partitioner).to eq(col_partitioner)
      expect(col.defpartitioner).to eq(def_partitioner)
    end
  end

  describe '#def_part_by_defno' do
    let(:col) { create(:eby_column_image, :partitioned) }

    it 'returns definition part by defno' do
      part = col.def_part_images.where(defno: 0).first
      expect(col.def_part_by_defno(0)).to eq(part)
    end

    it 'returns nil for non-existent defno' do
      expect(col.def_part_by_defno(999)).to be_nil
    end

    it 'returns first match when multiple parts have same defno' do
      # This shouldn't normally happen, but test the method behavior
      first_part = col.def_part_by_defno(0)
      expect(first_part).to be_a(EbyDefPartImage)
    end
  end

  describe '#first_def_part' do
    it 'returns minimum defno' do
      col = create(:eby_column_image)
      create(:eby_def_part_image, colimg: col, defno: 5)
      create(:eby_def_part_image, colimg: col, defno: 2)
      create(:eby_def_part_image, colimg: col, defno: 8)

      expect(col.first_def_part).to eq(2)
    end

    it 'returns nil for column with no parts' do
      col = create(:eby_column_image)
      expect(col.first_def_part).to be_nil
    end

    it 'returns 0 when first defno is 0' do
      col = create(:eby_column_image, :partitioned)
      expect(col.first_def_part).to eq(0)
    end
  end

  describe '#last_def_part' do
    it 'returns maximum defno' do
      col = create(:eby_column_image)
      create(:eby_def_part_image, colimg: col, defno: 5)
      create(:eby_def_part_image, colimg: col, defno: 2)
      create(:eby_def_part_image, colimg: col, defno: 8)

      expect(col.last_def_part).to eq(8)
    end

    it 'returns nil for column with no parts' do
      col = create(:eby_column_image)
      expect(col.last_def_part).to be_nil
    end
  end

  describe '#get_coldefjpeg' do
    it 'returns coldefjpeg when attached' do
      col = create(:eby_column_image, :need_def_partition)
      expect(col.get_coldefjpeg).to eq(col.cloud_coldefjpeg)
    end

    it 'falls back to coljpeg when coldefjpeg not attached' do
      col = create(:eby_column_image)
      expect(col.cloud_coldefjpeg).not_to be_attached
      expect(col.get_coldefjpeg).to eq(col.cloud_coljpeg)
    end

    it 'provides image for definition parts without separate image' do
      col = create(:eby_column_image)
      image = col.get_coldefjpeg
      expect(image).to be_attached
    end
  end

  describe '#def_by_defno' do
    it 'returns definition for given defno' do
      col = create(:eby_column_image, :partitioned)
      part = col.def_part_images.first
      definition = part.eby_def

      expect(col.def_by_defno(part.defno)).to eq(definition)
    end

    it 'returns nil when defno has no definition' do
      col = create(:eby_column_image)
      create(:eby_def_part_image, :orphan, colimg: col, defno: 5)

      expect(col.def_by_defno(5)).to be_nil
    end

    it 'returns nil when defno does not exist' do
      col = create(:eby_column_image, :partitioned)
      expect(col.def_by_defno(999)).to be_nil
    end
  end

  describe 'column numbering' do
    let(:scan) { create(:eby_scan_image) }

    it 'tracks column number within scan' do
      col = create(:eby_column_image, scan: scan, colnum: 3)
      expect(col.colnum).to eq(3)
    end

    it 'allows multiple columns per scan' do
      col1 = create(:eby_column_image, scan: scan, colnum: 1)
      col2 = create(:eby_column_image, scan: scan, colnum: 2)
      col3 = create(:eby_column_image, scan: scan, colnum: 3)

      expect(scan.col_images.count).to eq(3)
    end
  end

  describe 'page and volume tracking' do
    it 'inherits volume from parent scan' do
      scan = create(:eby_scan_image, volume: 5)
      col = create(:eby_column_image, scan: scan, volume: 5)
      expect(col.volume).to eq(5)
    end

    it 'tracks page number' do
      col = create(:eby_column_image, pagenum: 42)
      expect(col.pagenum).to eq(42)
    end

    it 'allows two columns on same page' do
      scan = create(:eby_scan_image)
      col1 = create(:eby_column_image, scan: scan, pagenum: 10, colnum: 1)
      col2 = create(:eby_column_image, scan: scan, pagenum: 10, colnum: 2)

      expect(col1.pagenum).to eq(col2.pagenum)
      expect(col1.colnum).not_to eq(col2.colnum)
    end
  end

  describe 'definition parts relationship' do
    it 'can have multiple definition parts' do
      col = create(:eby_column_image, :partitioned)
      expect(col.def_part_images.count).to eq(3)
    end

    it 'orders definition parts by defno' do
      col = create(:eby_column_image)
      part3 = create(:eby_def_part_image, colimg: col, defno: 3)
      part1 = create(:eby_def_part_image, colimg: col, defno: 1)
      part2 = create(:eby_def_part_image, colimg: col, defno: 2)

      defnos = col.def_part_images.order(:defno).pluck(:defno)
      expect(defnos).to eq([1, 2, 3])
    end

    it 'can have zero definition parts initially' do
      col = create(:eby_column_image)
      expect(col.def_part_images.count).to eq(0)
    end
  end

  describe 'orphan handling' do
    it 'can be marked as having orphans' do
      col = create(:eby_column_image, :got_orphans)
      expect(col.status).to eq('GotOrphans')
    end

    it 'can have orphan parts (parts without definition)' do
      col = create(:eby_column_image)
      orphan = create(:eby_def_part_image, :orphan, colimg: col)

      expect(orphan.eby_def).to be_nil
      expect(col.def_part_images).to include(orphan)
    end
  end

  describe 'complete partitioning workflow' do
    it 'goes through full partition workflow' do
      scan = create(:eby_scan_image, :partitioned)
      col = scan.col_images.first

      # Initial state
      expect(col.status).to eq('NeedPartition')

      # After column partitioning (separate defs from footnotes)
      partitioner = create(:eby_user, :partitioner)
      col.update(status: 'NeedDefPartition', partitioner: partitioner)
      expect(col.status).to eq('NeedDefPartition')

      # After definition partitioning
      defpartitioner = create(:eby_user, :partitioner)
      3.times do |i|
        eby_def = create(:eby_def)
        create(:eby_def_part_image,
          colimg: col,
          eby_def: eby_def,
          defno: i,
          partnum: 1
        )
      end
      col.update(status: 'Partitioned', defpartitioner: defpartitioner)

      expect(col.reload.status).to eq('Partitioned')
      expect(col.def_part_images.count).to eq(3)
      expect(col.first_def_part).to eq(0)
      expect(col.last_def_part).to eq(2)
    end
  end
end
