require File.dirname(__FILE__) + '/../test_helper'

class SfSystemFileTest < Test::Unit::TestCase
  fixtures :sf_channels
  fixtures :sf_setups
  fixtures :sf_simple_channels
  fixtures :sf_system_files
  fixtures :sf_system_tests
  fixtures :sf_test_plans
  fixtures :sites
  fixtures :sf_test_channels
  fixtures :analyzers

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_data_there
    assert_equal 2,SfSystemFile.count()
    assert_equal 3,SfTestPlan.count()
    assert_equal 5,SfChannel.count()
    assert_equal 3,SfSetup.count()
    assert_equal 3,SfSimpleChannel.count()
    assert_equal 3,SfSystemTest.count()
    assert_equal 5,SfTestChannel.count()
    assert_equal 5,Analyzer.count()
    sf_test_plan=SfTestPlan.find(1)
    #assert_equal 1,sf_test_plan.sites.count() #TODO Add sites to fixtures associated with this sf_test_plan.
    #assert_equal 1,Analyzer.find(1).sf_test_plan_id
  end
  def test_sf_cascading_destroy
    SfSystemFile.destroy(2)
    assert_equal 1,SfSystemFile.count()
    assert_equal 2,SfTestPlan.count()
    assert_equal 4,SfChannel.count()
    assert_equal 2,SfSetup.count()
    assert_equal 2,SfSimpleChannel.count()
    assert_equal 2,SfSystemTest.count()
    assert_equal 4,SfTestChannel.count()
    assert_equal 5,Analyzer.count()
    assert !Analyzer.find(4).site.nil?
    #TODO Add sites to fixtures associated with this analyzer.
    assert Analyzer.find(4).site 
    SfSystemFile.destroy(1)
    assert_equal 0,SfSystemFile.count()
    assert_equal 0,SfTestPlan.count()
    assert_equal 0,SfChannel.count()
    assert_equal 0,SfSetup.count()
    assert_equal 0,SfSimpleChannel.count()
    assert_equal 0,SfSystemTest.count()
    assert_equal 0,SfTestChannel.count()
    assert_equal 5,Analyzer.count()
    assert !Analyzer.find(4).site_id.nil?
  end
  def test_find_ch_by_freq
    sf=SfSystemFile.find(1)
    ch=sf.find_ch_by_freq(55_250_000)
    assert !ch.nil?
    assert_equal 0,ch.channel_type.to_i
    ch=sf.find_ch_by_freq(58250000)
    assert_nil ch
    ch=sf.find_ch_by_freq(75250000)
    assert !ch.nil?
    assert_equal 1,ch.channel_type.to_i
  end
end
