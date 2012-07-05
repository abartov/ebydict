require 'test_helper'

class ProblemControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get resolve" do
    get :resolve
    assert_response :success
  end

end
