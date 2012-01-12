require File.dirname(__FILE__) + '/../test_helper'

class DownAlarmTest < Test::Unit::TestCase
  fixtures :down_alarms, :measures

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_email_required
    alarm = DownAlarm.new
    alarm.alarm_type = 1

    # Provide no email address
    assert alarm.valid?, "Should not get errors on saving alarm with no email address provided"
    assert !alarm.errors.invalid?(:email)

    # Provide invalid email address (not _____@_____.____)
    #alarm = DownAlarm.new
    #alarm.alarm_type = 1
    #alarm.email = "hello"
    #assert !alarm.valid?, "Should get errors on saving alarm with invalid email address provided"
    #assert alarm.errors.invalid?(:email)
    #assert_equal "is invalid", alarm.errors.on(:email)

    # Provide valid email address (_____@_____.____)
    alarm = DownAlarm.new
    alarm.alarm_type = 1
    alarm.email = "hello@domain.com"
    assert alarm.valid?, "Should not get errors on saving alarm with valid email address provided (ERROR: #{alarm.errors.full_messages})"
    assert !alarm.errors.invalid?(:email)
    assert_nil alarm.errors.on(:email)
  end
  def test_activation
    site_id=101
    channel_id=1
    measure_id=1
    alarm=DownAlarm.generate( site_id,50,channel_id, measure_id,10,DownAlarm.error(),3,'Analog')
    assert 1,DownAlarm.count
    alarm=DownAlarm.generate( site_id,50,channel_id, measure_id,10,DownAlarm.error(),3,'Analog')
    assert 1,DownAlarm.count
    DownAlarm.deactivate(site_id,measure_id,channel_id,'Analog')
    assert 2,DownAlarm.count
    alm1=DownAlarm.find(1)
    assert 1,alm1.active
    alm2=DownAlarm.find(2)
    assert 1,alm2.active
    DownAlarm.deactivate(site_id, measure_id, channel_id,'Analog')
    alm2=DownAlarm.find(2)
    assert 0,alm2.active
 
  end
end
