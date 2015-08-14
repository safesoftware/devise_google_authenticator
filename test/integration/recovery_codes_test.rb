require 'test_helper'
require 'integration_tests_helper'

class InvitationTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false

  def teardown
    Capybara.reset_sessions!
    Timecop.return
  end

  test 'visit recovery codes page and download the recovery codes' do
    sign_in_as_user
    visit user_recovery_codes_path
    fill_in "user_current_password", with: "123456"
    click_on "Download codes"
    assert_equal 200, page.status_code
  end

  test 'visit recovery codes page and download the recovery codes with invalid password' do
    sign_in_as_user
    visit user_recovery_codes_path
    fill_in "user_current_password", with: "foobar"
    click_on "Download codes"
    assert_equal 401, page.status_code
  end

  test 'successful login using a recovery code' do
    sign_in_as_user
    tmp_user = User.find(1)
    tmp_user.gauth_enabled = 1
    tmp_user.save!
    visit user_recovery_codes_path
    fill_in "user_current_password", with: "123456"
    click_on "Download codes"
    recovery_code = page.body.match(/<p>(.*)\n/)[1]

    Capybara.reset_sessions!

    visit new_user_session_path
    fill_in 'user_email', :with => 'fulluser@test.com'
    fill_in 'user_password', :with => '123456'
    click_button 'Sign in'
    click_on "Enter a recovery code"
    fill_in 'user_gauth_recovery_code', with: recovery_code
    click_on "Verify"
    assert_equal root_path, current_path
  end

  test 'unsuccessful login using an invalid recovery code' do
    create_and_signin_gauth_user
    click_on "Enter a recovery code"
    fill_in 'user_gauth_recovery_code', with: "xyz"
    click_on "Verify"
    assert_not_equal root_path, current_path
    assert_equal new_user_session_path, current_path
  end

end