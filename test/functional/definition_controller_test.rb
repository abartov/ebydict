require 'test_helper'

class DefinitionControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    #assert_response :success
    assert_redirected_to(controller: :login, action: :login) # when not logged in
    u = users(:admin)
    # TODO: login
    # test actual list view
  end

  test "should get review" do
    get :review
    assert_response :success
  end

  test "should get publish" do
    get :publish
    assert_response :success
  end

  test "should get reproof" do
    get :reproof
    assert_response :success
  end
  test "should get view" do
    get :view, {:id => eby_defs(:one).id}
    assert_response :success
  end
end
