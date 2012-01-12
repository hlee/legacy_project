require File.dirname(__FILE__) + '/../test_helper'

class SfTestPlanTest < Test::Unit::TestCase
  fixtures :sf_test_plans
  fixtures :sf_system_tests

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_find_test
     sf_test_plan=SfTestPlan.find(1)
     sf_test=sf_test_plan.find_test(10)[0]
     assert_equal 100,sf_test.min_value
     assert_equal 1000,sf_test.max_value
     sf_test=sf_test_plan.find_test(11)[0]
     assert_equal 200,sf_test.min_value
     assert_equal 2000,sf_test.max_value
     sf_test=sf_test_plan.find_test(12)[0]
     assert sf_test.nil?
  end
end
