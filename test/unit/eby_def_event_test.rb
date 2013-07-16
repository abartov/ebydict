require 'test_helper'

class EbyDefEventTest < ActiveSupport::TestCase
  test "shouldn't save invalid record" do
    ev = EbyDefEvent.new
    assert !ev.save
    ev.new_status = 'Partial'
    assert !ev.save
    ev.old_status = 'NoSuch'
    assert !ev.save
    ev.old_status ='NeedProof2'
    assert ev.save
  end
end
