require 'test_helper'

class EbyDefPartImageTest < ActiveSupport::TestCase
  test "shouldn't save an invalid record" do
    col = EbyColumnImage.first
    dp = EbyDefPartImage.new
    assert !dp.save
    dp.colimg = col
    dp.defno = 'NaN'
    assert !dp.save
    dp.defno = 3
    dp.partnum = 'NaN'
    assert !dp.save
    dp.partnum = 1
    assert dp.save # should succeed
    dp.eby_def = EbyDef.first
    dp.save # should also succeed
  end
end
