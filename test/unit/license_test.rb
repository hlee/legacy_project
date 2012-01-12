require File.join(File.dirname(__FILE__), "..", "test_helper")
require 'license'
class LicenseTest < Test::Unit::TestCase
  def test_new_license
    assert License.new
  end
  def test_new_license_without_filename
    license = License.new
    assert license
    assert !license.has_ingress?
    assert !license.has_performance?
  end
=begin
  def test_new_license_with_filename
    license = License.new('test/fixtures/license.txt.asc')
    assert license
    assert license.valid?
    assert_equal '', license.error_text
    assert_equal '23 Apr 2009', license.expiration_date
    assert_equal 'test/fixtures/license.txt.asc', license.filename
    assert_equal ' ', license.mac_address
    assert license.has_ingress?
    assert !license.has_performance?
  end
  def test_license_change_filename_updates_last_verified
    license = License.new('test/fixtures/license.txt.asc')
    puts license.inspect
    assert license
    assert license.valid?
    assert_equal '', license.error_text
    assert_equal '23 Apr 2009', license.expiration_date
    assert_equal 'test/fixtures/license.txt.asc', license.filename
    assert_equal ' ', license.mac_address
    assert license.has_ingress?
    assert !license.has_performance?

    before_verified = license.last_verified
    # Wait at least one second so the last_verified times will be
    # different
    sleep 1
    assert license.filename = 'test/fixtures/license_bad.txt.asc'
    after_verified = license.last_verified
    assert_not_equal before_verified, after_verified, "last_verified field should be updated on a filename change."
  end
=end
end
