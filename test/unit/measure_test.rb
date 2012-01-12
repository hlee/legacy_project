require File.dirname(__FILE__) + '/../test_helper'

class MeasureTest < Test::Unit::TestCase
  fixtures :measures
  fixtures :down_alarms

  # Replace this with your real tests.
  def test_measures
     assert_equal 14,Measure.count()
     assert_equal 14,Measure.find(:all).length
     assert_equal 3,Measure.alarmed().length
  end
end
