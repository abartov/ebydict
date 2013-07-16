require 'test_helper'

class EbyUserTest < ActiveSupport::TestCase
  test "shouldn't save invalid record" do
    u = EbyUser.new
    assert !u.save
    u.login = 'abcdef'
    assert !u.save
    u.password = 'Thucydides is awesome!'
    assert !u.save
    u.email = 'joebloggs@mailinator.com'
    assert !u.save
    u.fullname = 'Joe Bloggs'
    assert u.save # minimal record
    u.password = 'oo' # too short
    assert !u.save
    u.password = 'Herodotus is awesome too!'
    u.email = 'oo' # too short
    assert !u.save
    u.email = 'joebloggs@mailinator.com'
    assert u.save
  end
end
