require 'test_helper'

class EbyScanImageTest < ActiveSupport::TestCase
  test "should not save invalid record" do
    rec = EbyScanImage.new
    assert !rec.save
    rec.volume = 1
    assert !rec.save
    rec.volume = 'invalid'
    rec.origjpeg = '/var/www/v1/page0001.jpg'
    assert !rec.save
    rec.firstpagenum = 34
    assert !rec.save
    rec.volume = 2
    rec.firstpagenum = 'NaN'
    assert !rec.save
    rec.firstpagenum = 23
    rec.status = 'NoSuchStatus'
    assert !rec.save
  end
end
