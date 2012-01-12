require File.dirname(__FILE__) + '/../test_helper'

class ScheduleTest < Test::Unit::TestCase
  fixtures :schedules, :analyzers, :switches,:switch_ports

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_init_schedule
    #Analyzer1
    sched=Schedule.create(:analyzer_id=>1, :acquisition_count=>1, :trace_polling_period=>15)
    sched.init_schedule_dtls()
    assert sched.verify_scheduled_ports
    assert_equal 80,sched.scheduled_sources.count
    assert sched.verify_scheduled_ports
    sched.scheduled_sources[0].update_attribute(:switch_port_id,100)
    sched.errors.clear()
    # Updated to fix build errors.
    assert !sched.verify_scheduled_ports
    assert_equal "Switch ports change, re-init schedule",sched.errors.full_messages()[0]
    #break_src=sched.scheduled_sources.delete_all()
    #assert !sched.verify_scheduled_ports
    #Analyzer2
=begin cause by code change. we don't check No ports scheduled problem.
    sched=Schedule.create(:analyzer_id=>2, :acquisition_count=>1, :trace_polling_period=>15)
    sched.errors.clear()
    sched.init_schedule_dtls()
    assert !sched.verify_scheduled_ports, sched.errors.inspect()
    assert_equal 1,sched.errors.count()
    assert_equal "No ports scheduled",sched.errors.full_messages()[0]
    assert_equal 0,sched.scheduled_sources.count

    #Analyzer3
    sched=Schedule.create(:analyzer_id=>3, :acquisition_count=>1, :trace_polling_period=>15)
    sched.init_schedule_dtls()
    assert !sched.verify_scheduled_ports
    assert_equal 0,sched.scheduled_sources.count
    #Analyzer4
    sched=Schedule.create(:analyzer_id=>4, :acquisition_count=>1, :trace_polling_period=>15)
    sched.init_schedule_dtls()
    assert !sched.verify_scheduled_ports
    assert_equal 0,sched.scheduled_sources.count
=end	
    #Analyzer5
    sched=Schedule.create(:analyzer_id=>5, :acquisition_count=>1, :trace_polling_period=>15)
    sched.init_schedule_dtls()
    assert sched.verify_scheduled_ports
    assert_equal 32,sched.scheduled_sources.count
    assert sched.verify_scheduled_ports
    sched.scheduled_sources[0].update_attribute(:switch_port_id,100)
    sched.errors.clear()
    #Analyzer6
    sched=Schedule.create(:analyzer_id=>6, :acquisition_count=>1, :trace_polling_period=>15)
    assert_equal 0,sched.scheduled_sources.count
    assert_raise(RuntimeError) do
      sched.init_schedule_dtls()
    end
    #assert !sched.verify_scheduled_ports
   
  end
end
