require 'test_helper'

class DefinitionControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
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

end
