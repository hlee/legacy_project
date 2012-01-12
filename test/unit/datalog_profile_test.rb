require File.dirname(__FILE__) + '/../test_helper'


class DatalogProfileTest < ActiveSupport::TestCase
  fixtures :datalogs, :datalog_profiles, :config_params, :analyzers
  # Replace this with your real tests.
  def setup
  end
  def test_display_values
    dlp=DatalogProfile.find(1)
    assert_equal 'Max. Trace',  dlp.datalog_descr
    assert_equal 'Average of the four frequencies must be above limit',dlp.trigger_type_descr
    assert_equal 1000.0, dlp.bandwidth_disp
    assert_equal 12.0, dlp.freq1_disp
  end
  def test_trace_test
    dl=Datalog.find(:first)
    dlp=DatalogProfile.find(1)
  #Average Tests
    assert_equal true, dlp.test_trace(dl)
    dlp.limit_val=-19
    assert_equal false, dlp.test_trace(dl)
    dlp.limit_val=-20
    assert_equal false, dlp.test_trace(dl)
    dlp.limit_val=-21
    assert_equal true, dlp.test_trace(dl)
  #Max Tests
    dlp.limit_val=-19
    dlp.trigger_type=2
    dlp.freq_count=1
    assert_equal true, dlp.test_trace(dl)
    dlp.freq_count=2
    assert_equal false, dlp.test_trace(dl)
    dlp.freq_count=2
    dlp.limit_val=-20
    assert_equal true, dlp.test_trace(dl)
    dlp.freq_count=3
    dlp.limit_val=-20
    assert_equal false, dlp.test_trace(dl)
    dlp.limit_val=-22
    assert_equal true, dlp.test_trace(dl)
    dlp.freq_count=4
    dlp.limit_val=-22
    assert_equal true, dlp.test_trace(dl)
    trace=dlp.draw_trace
    assert_equal 60.0,trace[71]
    assert_equal -22,trace[72]
    assert_equal -22,trace[73]
    assert_equal -22,trace[74]
    assert_equal -22,trace[82]
    assert_equal -22,trace[83]
    assert_equal -22,trace[84]
    assert_equal  60,trace[85]
  end
  def test_trace_test_set
    dl=Datalog.find(:first)
    c1=Alarm.count()
    DatalogProfile.test_trace_set(dl)
    c2=Alarm.count()
    assert_equal c1+1,c2
    dp=DatalogProfile.find(:first)
    dp.datalog_trace=2
    dp.save
    DatalogProfile.test_trace_set(dl)
  end
end
