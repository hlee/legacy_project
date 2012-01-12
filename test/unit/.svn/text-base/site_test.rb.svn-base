require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites,:alarms,:down_alarms,:datalogs,:measurements,:analyzers, :switch_ports, :profiles

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_create_if_needed
    assert_equal 17,Site.count()
    Site.create_if_needed("bob")
    assert_equal 18,Site.count()
    Site.create_if_needed("bob")
    assert_equal 18,Site.count()
    Site.create_if_needed("bob2")
    assert_equal 19,Site.count()
    assert !Site.find(:first,{:conditions=>["name=?","bob"]}).nil?
    assert !Site.find(:first,{:conditions=>["name=?","bob2"]}).nil?
    assert Site.find(:first,{:conditions=>["name=?","bob3"]}).nil?
  end
  def test_alarm_sites 
     result=Site.alarm_sites(:upstream)#Get all the sites with downstream alarms
     assert_equal 3,result.length#Get all the sites with upstream alarms
     assert_equal 2,Site.alarm_sites(:downstream).length#Get all the sites with downstream alarms
     assert_equal 5,Site.alarm_sites().length#Get all the sites with alarms
     assert_equal 4,Site.data_sites(:upstream).length#Get all the sites with upstream data
     assert_equal 2,Site.data_sites(:downstream).length#Get all the sites with downstream data
     first_rec=Site.alarm_sites()[0]
     assert_equal 2,first_rec.length
     assert_equal 101,first_rec[1]
  end
  def test_analyzer_link
    site=Site.find(101)
    anl=site.analyzer
    assert_equal 1,anl.id
    site=Site.find(103)
    anl=site.analyzer
    assert_equal 3,anl.id
    site=Site.find(106)
    anl=site.analyzer
    assert_equal 1,anl.id
  end
  def test_port_link
    site=Site.find(101)
    aport=site.analyzer_port
    assert aport.nil?
    site=Site.find(103)
    aport=site.analyzer_port
    assert aport.nil?
    site=Site.find(106)
    aport=site.analyzer_port
    assert_equal 5,aport.id
  end
  def test_get_profile
    site=Site.find(101)
    profile=site.get_profile
    assert_equal 5000,profile.id
    site=Site.find(102)
    profile=site.get_profile
    assert_equal 5002,profile.id
    site=Site.find(104)
    profile=site.get_profile
    assert_equal 5000,profile.id
    site=Site.find(103)
    profile=site.get_profile
    assert_nil profile
  end
end
