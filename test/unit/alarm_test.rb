require File.dirname(__FILE__) + '/../test_helper'

class AlarmTest < Test::Unit::TestCase
  fixtures :sites,:profiles,:config_params,:alarms

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_email_required
    alarm = Alarm.new

    # Provide no email address
    assert alarm.valid?, "Should not get errors on saving alarm with no email address provided"
    assert !alarm.errors.invalid?(:email)

    # Provide invalid email address (not _____@_____.____) we will not test bug#6627 "email validation will block alarm create"
    #alarm = Alarm.new
    #alarm.email = "hello"
    #assert !alarm.valid?, "Should get errors on saving alarm with invalid email address provided"
    #assert alarm.errors.invalid?(:email)
    #assert_equal "is invalid", alarm.errors.on(:email)

    # Provide valid email address (_____@_____.____)
    alarm = Alarm.new
    alarm.email = "hello@domain.com"
    assert alarm.valid?, "Should not get errors on saving alarm with valid email address provided"
    assert !alarm.errors.invalid?(:email)
    assert_nil alarm.errors.on(:email)
  end
  
  def test_activation
    count=Alarm.count
    assert_equal count,Alarm.count
    site_id=101
    profile_id=Profile.find(:first).id
    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :sched_sn_nbr           => 1,
          :step_nbr               => 2,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2007,11,1,19,13,14),
          :event_time_hundreths   => 30,
          :alarm_level            => 1,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 0 == 0 ? Alarm.major() : Alarm.minor()
        )
    first_alarm=alarm
    assert_equal count+1 ,Alarm.count
    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :sched_sn_nbr           => 1,
          :step_nbr               => 2,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2007,11,1,19,13,16),
          :event_time_hundreths   => 30,
          :alarm_level            => 1,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 0 == 0 ? Alarm.major() : Alarm.minor()
        )
    assert_equal count+2,Alarm.count
    Alarm.deactivate(site_id)
    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :sched_sn_nbr           => 1,
          :step_nbr               => 2,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2007,11,1,19,13,16),
          :event_time_hundreths   => 30,
          :alarm_level            => 1,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 0 == 0 ? Alarm.major() : Alarm.minor()
        )
    assert_equal count+3,Alarm.count
    assert alarm.active
    assert first_alarm.active
    Alarm.deactivate(site_id)

    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :sched_sn_nbr           => 2,
          :step_nbr               => 2,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2007,11,1,19,13,16),
          :event_time_hundreths   => 30,
          :alarm_level            => 128,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 0 )
      assert_equal Alarm.minor,alarm.alarm_type 
      assert_equal "MINOR (Trouble)",alarm.level_txt
    Alarm.deactivate(site_id)
    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :sched_sn_nbr           => 3,
          :step_nbr               => 2,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2007,11,1,19,13,16),
          :event_time_hundreths   => 30,
          :alarm_level            => 130,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 0 )
      assert_equal Alarm.major,alarm.alarm_type 
      assert_equal "MAJOR (Trouble)",alarm.level_txt

    alarm=Alarm.generate(
          :profile_id             => profile_id,
          :site_id                => site_id,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.civil( 2009,11,1,19,13,16),
          :event_time_hundreths   => 30,
          :alarm_level            => 0,
          :external_temp          => 53,
          :center_frequency       => 40_000_000 ,
          :span                   => 80_000_000 ,
          :email                  => "",
          :alarm_type             => 10 )
     assert_equal false,alarm.active
     assert_equal  Profile.find(:first).name + "(Datalog Profile)", alarm.level_txt 
 
  end
end
