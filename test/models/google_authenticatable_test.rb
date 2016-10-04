require 'test_helper'
require 'model_tests_helper'

class GoogleAuthenticatableTest < ActiveSupport::TestCase

	def setup
		new_user
	end

	test 'new users have a non-nil secret set' do
		assert_not_nil User.find(1).gauth_secret
	end

	test 'new users should have gauth_enabled disabled by default' do
		assert_equal 0, User.find(1).gauth_enabled.to_i
	end

	test 'get_qr method works' do
		assert_not_nil User.find(1).get_qr
	end

	test 'updating gauth_enabled to true' do
		User.find(1).set_gauth_enabled(:gauth_enabled => 1)
		assert_equal 1, User.find(1).gauth_enabled.to_i
	end

	test 'updating gauth_enabled back to false' do
		User.find(1).set_gauth_enabled(:gauth_enabled => 0)
		assert_equal 0, User.find(1).gauth_enabled.to_i
	end

	test 'updating the gauth_tmp key' do
		User.find(1).assign_tmp
		
		assert_not_nil User.find(1).gauth_tmp
		assert_not_nil User.find(1).gauth_tmp_datetime
		
		sleep(1)
		
		old_tmp = User.find(1).gauth_tmp
		old_dt = User.find(1).gauth_tmp_datetime
		
		User.find(1).assign_tmp

		assert_not_equal old_tmp, User.find(1).gauth_tmp
		assert_not_equal old_dt, User.find(1).gauth_tmp_datetime
	end

	test 'testing class method for finding by tmp key' do
		assert User.find_by(gauth_tmp: 'invalid').nil?
		assert !User.find_by(gauth_tmp: User.find(1).gauth_tmp).nil?
	end

	test 'testing token validation' do
		assert !User.find(1).validate_token('1')
		assert !User.find(1).validate_token(ROTP::TOTP.new(User.find(1).get_qr).at(Time.now))

		User.find(1).assign_tmp

		assert !User.find(1).validate_token('1')
		assert User.find(1).validate_token(ROTP::TOTP.new(User.find(1).get_qr).at(Time.now))
	end

	test 'requiring token after remembertime' do
		u = User.find(1)
		assert u.require_token?(nil)
		assert u.require_token?(u.email + "," + 2.months.ago.to_i.to_s)
		assert !u.require_token?(u.email + "," + 1.day.ago.to_i.to_s)
		assert u.require_token?("testxx@test.com" + "," + 1.day.ago.to_i.to_s)
  end

  test 'create recovery codes' do
    u = User.find(1)
    u.create_recovery_codes
    assert_equal u.gauth_recovery_codes.class, Array
    assert_equal u.gauth_recovery_codes.length, 20
  end

  test 'checking a recovery code for its validity' do
    u = User.find(1)
    unencrypted = u.create_recovery_codes
    assert_equal true, u.valid_recovery_code?(unencrypted[0])
    assert_equal false, u.valid_recovery_code?('badPwd')
    assert_equal 19, u.gauth_recovery_codes.length
  end

end