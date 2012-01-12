require File.dirname(__FILE__) + '/../test_helper'

class SwitchPortTest < Test::Unit::TestCase
  fixtures :switch_ports
  fixtures :sites
  fixtures :switches
  fixtures :analyzers
  fixtures :sf_test_plans

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_count
    swports=SwitchPort.find(:all)
    assert_equal 112,swports.length
  end
  def test_finds
    switch_port=SwitchPort.find(1)
    assert_equal 1, switch_port.id
  end
  def test_get_test_plan
    switch_port=SwitchPort.find(1)
		assert_equal 102,switch_port.get_site().id
	#	assert_equal 1,switch_port.get_test_plan().id
    switch_port=SwitchPort.find(2)
		assert_equal 101,switch_port.get_site().id
	#	assert_equal 1,switch_port.get_test_plan().id
    switch_port=SwitchPort.find(79)
		assert switch_port.get_site()
	#	assert switch_port.get_test_plan()
  end
  def test_site_generation
    site_count=Site.find(:all).length
    swp=SwitchPort.create({:name => "Fake"})
    assert !swp.id.nil?, "Failure Reason:" + swp.errors.full_messages.join(' | ')
    assert_equal Site.find(:all).length,site_count+1, "Expected #{site_count+1} sites to be created but only had #{Site.find(:all).length} created"
    assert !SwitchPort.find(swp.id).nil?
    assert !swp.site_id.nil?, "Created switch port cannot have a nil site"
    assert !swp.site.nil?, "Created switch port cannot have a nil site"
  end
end
