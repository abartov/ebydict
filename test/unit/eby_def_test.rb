require 'test_helper'

class EbyDefTest < ActiveSupport::TestCase
  test "shouldn't save invalid record" do
    d = EbyDef.new
    assert !d.save
    d.volume = 1
    assert !d.save
    d.status = 'NeedFixup'
    d.volume = 'NaN'
    assert !d.save
    d.volume = 1
    d.arabic = d.russian = d.extra = 'todo'
    d.greek = 'todoo' # intentional typo
    assert !d.save
    d.greek = 'done'
    d.proof_round_passed = 'NaN'
    assert !d.save
    d.proof_round_passed = 2
    d.reject_count = 'NaN'
    assert !d.save
    d.reject_count = 0
    d.ordinal = 'NaN'
    assert !d.save
    d.ordinal = 12
    d.status = 'NoSuch'
    assert !d.save
    d.status = 'NeedTyping'
    assert d.save # should work
    ev = EbyDefEvent.new
    assert !ev.save
    d.events << ev
    assert !d.save # should't save with an invalid event
    ev.new_status = 'NeedFixup'
    ev.old_status = 'NeedTyping'
    assert ev.save
    assert d.save
  end
end
