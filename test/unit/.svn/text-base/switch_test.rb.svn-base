require File.dirname(__FILE__) + '/../test_helper'

class SwitchTest < Test::Unit::TestCase
  fixtures :switches, :analyzers

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_count
    assert_equal 8,Switch.count
  end
  def test_switches
    switch=Switch.find(1)
    assert  !switch.nil?
    switches=Switch.find(:all)
    assert !switch.analyzer.nil?, "No analyzer for switch "
    assert_equal 8, switches.length
    assert_raises(ActiveRecord::RecordNotFound) do
       analyzer=Switch.find(10)
    end
  end
    
end
