require 'test_helper'

class EbyAliasesControllerTest < ActionDispatch::IntegrationTest
  test "should get review" do
    get eby_aliases_review_url
    assert_response :success
  end

  test "should get confirm" do
    get eby_aliases_confirm_url
    assert_response :success
  end

  test "should get reject" do
    get eby_aliases_reject_url
    assert_response :success
  end

end
