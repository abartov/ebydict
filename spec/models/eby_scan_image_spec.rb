# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EbyScanImage, type: :model do
  describe 'associations' do
    it { should have_many(:col_images).class_name('EbyColumnImage').with_foreign_key('eby_scan_image_id') }
    it { should belong_to(:assignee).class_name('EbyUser').with_foreign_key('assignedto').optional }
    it { should belong_to(:partitioner).class_name('EbyUser').with_foreign_key('partitioned_by').optional }
  end

  describe 'validations' do
    subject { build(:eby_scan_image) }

    it { should validate_presence_of(:origjpeg) }
    it { should validate_uniqueness_of(:origjpeg) }
    it { should validate_presence_of(:volume) }
    it { should validate_numericality_of(:volume) }
    it { should validate_numericality_of(:firstpagenum).allow_nil }
    it { should validate_numericality_of(:secondpagenum).allow_nil }
    it { should validate_uniqueness_of(:smalljpeg).allow_nil }
    it { should validate_inclusion_of(:status).in_array(%w[NeedPartition Partitioned]) }
  end

  describe 'ActiveStorage attachments' do
    it 'has cloud_origjpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_origjpeg)
    end

    it 'has cloud_smalljpeg attachment' do
      expect(described_class.new).to respond_to(:cloud_smalljpeg)
    end

    it 'can attach original image' do
      scan = create(:eby_scan_image)
      expect(scan.cloud_origjpeg).to be_attached
    end

    it 'can attach small preview image' do
      scan = create(:eby_scan_image, :with_small_jpeg)
      expect(scan.cloud_smalljpeg).to be_attached
    end
  end

  describe 'status workflow' do
    it 'starts as NeedPartition' do
      scan = create(:eby_scan_image)
      expect(scan.status).to eq('NeedPartition')
    end

    it 'transitions to Partitioned after partitioning' do
      scan = create(:eby_scan_image, :partitioned)
      expect(scan.status).to eq('Partitioned')
    end

    it 'tracks who partitioned it' do
      partitioner = create(:eby_user, :partitioner)
      scan = create(:eby_scan_image, partitioner: partitioner, status: 'Partitioned')
      expect(scan.partitioner).to eq(partitioner)
      expect(scan.partitioned_by).to eq(partitioner.id)
    end
  end

  describe 'assignment' do
    it 'can be assigned to a user' do
      user = create(:eby_user, :partitioner)
      scan = create(:eby_scan_image, :assigned, assignee: user)
      expect(scan.assignee).to eq(user)
      expect(scan.assignedto).to eq(user.id)
    end

    it 'can be unassigned' do
      scan = create(:eby_scan_image, :unassigned)
      expect(scan.assignee).to be_nil
      expect(scan.assignedto).to be_nil
    end

    it 'allows reassignment' do
      user1 = create(:eby_user, :partitioner)
      user2 = create(:eby_user, :partitioner)
      scan = create(:eby_scan_image, assignee: user1)

      scan.update(assignee: user2)
      expect(scan.assignee).to eq(user2)
    end
  end

  describe 'page numbering' do
    it 'stores first page number' do
      scan = create(:eby_scan_image, firstpagenum: 42)
      expect(scan.firstpagenum).to eq(42)
    end

    it 'stores second page number' do
      scan = create(:eby_scan_image, secondpagenum: 43)
      expect(scan.secondpagenum).to eq(43)
    end

    it 'allows nil page numbers' do
      scan = build(:eby_scan_image, firstpagenum: nil, secondpagenum: nil)
      expect(scan).to be_valid
    end

    it 'validates page numbers are numeric' do
      scan = build(:eby_scan_image, firstpagenum: 'abc')
      expect(scan).not_to be_valid
    end
  end

  describe 'volume tracking' do
    it 'requires volume to be set' do
      scan = build(:eby_scan_image, volume: nil)
      expect(scan).not_to be_valid
    end

    it 'validates volume is numeric' do
      scan = build(:eby_scan_image, volume: 'one')
      expect(scan).not_to be_valid
    end

    it 'allows any numeric volume' do
      scan = create(:eby_scan_image, volume: 5)
      expect(scan.volume).to eq(5)
    end
  end

  describe '#columns' do
    it 'returns 0 for scan with no columns' do
      scan = create(:eby_scan_image)
      expect(scan.columns).to eq(0)
    end

    it 'returns count of column images' do
      scan = create(:eby_scan_image, :partitioned)
      expect(scan.columns).to eq(2)
    end

    it 'updates count when columns are added' do
      scan = create(:eby_scan_image)
      expect(scan.columns).to eq(0)

      create(:eby_column_image, scan: scan)
      expect(scan.reload.columns).to eq(1)

      create(:eby_column_image, scan: scan)
      expect(scan.reload.columns).to eq(2)
    end
  end

  describe 'image file naming' do
    it 'has unique origjpeg filename' do
      scan1 = create(:eby_scan_image, origjpeg: 'scan_001.jpg')
      scan2 = build(:eby_scan_image, origjpeg: 'scan_001.jpg')
      expect(scan2).not_to be_valid
    end

    it 'has unique smalljpeg filename when present' do
      scan1 = create(:eby_scan_image, smalljpeg: 'small_001.jpg')
      scan2 = build(:eby_scan_image, smalljpeg: 'small_001.jpg')
      expect(scan2).not_to be_valid
    end

    it 'allows multiple scans with nil smalljpeg' do
      scan1 = create(:eby_scan_image, smalljpeg: nil)
      scan2 = create(:eby_scan_image, smalljpeg: nil)
      expect(scan1).to be_valid
      expect(scan2).to be_valid
    end
  end

  describe 'complete partitioning workflow' do
    it 'creates scan, assigns, partitions, and creates columns' do
      # Import scan
      scan = create(:eby_scan_image, status: 'NeedPartition', volume: 1, firstpagenum: 10)
      expect(scan.status).to eq('NeedPartition')
      expect(scan.columns).to eq(0)

      # Assign to partitioner
      partitioner = create(:eby_user, :partitioner)
      scan.update(assignee: partitioner)
      expect(scan.assignee).to eq(partitioner)

      # Create columns (simulating partition action)
      col1 = create(:eby_column_image, scan: scan, colnum: 1, pagenum: 10, volume: 1)
      col2 = create(:eby_column_image, scan: scan, colnum: 2, pagenum: 10, volume: 1)

      # Mark as partitioned
      scan.update(status: 'Partitioned', partitioner: partitioner)

      expect(scan.reload.status).to eq('Partitioned')
      expect(scan.columns).to eq(2)
      expect(scan.partitioner).to eq(partitioner)
    end
  end

  describe 'edge cases' do
    it 'handles scans with many columns' do
      scan = create(:eby_scan_image)
      10.times { |i| create(:eby_column_image, scan: scan, colnum: i + 1) }
      expect(scan.reload.columns).to eq(10)
    end

    it 'handles very long filenames' do
      long_name = 'a' * 200 + '.jpg'
      scan = build(:eby_scan_image, origjpeg: long_name)
      # Should still be valid (no length validation)
      expect(scan).to be_valid
    end

    it 'handles high volume numbers' do
      scan = create(:eby_scan_image, volume: 999)
      expect(scan.volume).to eq(999)
    end

    it 'handles high page numbers' do
      scan = create(:eby_scan_image, firstpagenum: 5000, secondpagenum: 5001)
      expect(scan.firstpagenum).to eq(5000)
      expect(scan.secondpagenum).to eq(5001)
    end
  end
end
