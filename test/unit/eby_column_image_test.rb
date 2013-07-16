require 'test_helper'

class EbyColumnImageTest < ActiveSupport::TestCase
  test "should not save invalid record" do
    sc = EbyScanImage.first
    col = EbyColumnImage.new
    assert !col.save
    col.coljpeg = 'col0001.jpg'
    assert !col.save
    col.status = 'NoSuchStatus'
    assert !col.save
    col.status = 'GotOrphans'
    col.colnum = 'NaN'
    assert !col.save
    col.colnum = 3
    assert !col.save
    col.scan = sc
    assert !col.save
    col.pagenum = 1
    # should be savable at this point
    assert col.save
    col = EbyColumnImage.first
    col.status = 'NoSuchStatus'
    assert !col.save
    col.status = 'Partitioned'
    col.colnum = 'NaN'
    assert !col.save
    col.colnum = 1
    col.status = nil
    assert !col.save
    col.status = 'NeedPartition'
    col.coljpeg = nil
    assert !col.save
    col.coljpeg = 'col0002.jpg'
    col.pagenum = 'NaN'
    assert !col.save
    col.pagenum = nil
    assert !col.save
  end

end
