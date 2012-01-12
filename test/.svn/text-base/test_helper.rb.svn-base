ENV['RAILS_ENV'] = "test"
ENV['SKIP_AUTH'] = "yes"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
end

def get_license
  license = ConfigParam.find_by_name("License")
  assert !license.nil?, "Could not find ConfigParam 'license'"
  return license.val
end

def set_license_neither
  # config_params sets license to none, we want both
  license = ConfigParam.find_by_name("License")
  assert !license.nil?, "Could not find ConfigParam 'license'"
  license.val = "NEITHER"
  assert license.save, "ERROR: Unable to set license code to NEITHER (ERROR: #{license.errors.full_messages})"
end

def set_license_both
  # config_params sets license to none, we want both
  license = ConfigParam.find_by_name("License")
  assert !license.nil?, "Could not find ConfigParam 'license'"
  license.val = "BOTH"
  assert license.save, "ERROR: Unable to set license code to BOTH (ERROR: #{license.errors.full_messages})"
end

def set_license_ingress
  # config_params sets license to none, we want both
  license = ConfigParam.find_by_name("License")
  assert !license.nil?, "Could not find ConfigParam 'license'"
  license.val = "INGRESS"
  assert license.save, "ERROR: Unable to set license code to INGRESS (ERROR: #{license.errors.full_messages})"
end

def set_license_performance
  # config_params sets license to none, we want both
  license = ConfigParam.find_by_name("License")
  assert !license.nil?, "Could not find ConfigParam 'license'"
  license.val = "PERFORMANCE"
  assert license.save, "ERROR: Unable to set license code to PERFORMANCE (ERROR: #{license.errors.full_messages})"
end

