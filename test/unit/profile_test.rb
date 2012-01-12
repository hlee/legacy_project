require File.dirname(__FILE__) + '/../test_helper'


class ProfileTest < Test::Unit::TestCase
  fixtures :profiles, :config_params, :analyzers, :switches, :switch_ports
  def setup
     #Profile.delete_all();
     20.times { |index|
        prof=Profile.new()
        #prof.id=index
        prof.name="PROF_"+index.to_s
        prof.status=1
        prof.major_offset = 20
        prof.minor_offset = 10
        image_arr=[]
        500.times { |trace_index|
           val=750-trace_index*index
           image_arr.push(val)
        }
        prof.trace=image_arr
        prof.save()
     }
     #Let's build some test data 
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  def test_profile_edit_on_ingress_analyzer
    profile = Profile.find(5000)
    assert profile.valid?
    analyzer = Analyzer.find(1)
    analyzer.profile_id = profile.id
    analyzer.status = Analyzer::INGRESS
    assert analyzer.save

    # Try to change the default profile on an analyzer that is in Ingress mode.
    # Should fail validation
    profile.errors.clear()
    profile.major_offset = 10
    assert !profile.valid?, "Should get errors on changing profile while profile is in use."
    assert_equal "One or more Analyzers are in Ingress Monitoring mode and use this profile.  Edits are disabled until you stop Ingress Monitoring.", profile.errors.full_messages.join("\n")

    # Try to change a profile for a Ingress switch on an analyzer that is in Ingress mode.
    # Should fail validation
    analyzer.profile_id = 5001
    assert analyzer.save
    profile = Profile.find(5000)
    profile.errors.clear()
    profile.major_offset = 10
    assert profile.valid?, "Should not get errors on changing profile while profile is in use."
    assert_equal "", profile.errors.full_messages.join("\n")

    # Now set one of the switch ports to Profile 5000 and see if it errors correctly
    switch_port = analyzer.switches[0].switch_ports[0]
    switch_port.profile_id = 5000
    switch_port.purpose = SwitchPort::RETURN_PATH
    switch_port.save
    profile = Profile.find(5000)
    profile.errors.clear()
    profile.major_offset = 15
    assert !profile.valid?, "Should get errors on changing profile while profile is in use."
    assert_equal "One or more Analyzers are in Ingress Monitoring mode and use this profile.  Edits are disabled until you stop Ingress Monitoring on analyzer1.", profile.errors.full_messages.join("\n")
  end
  def test_datalog_build
    # We have a default profile, plus the 20 we load in setup
    assert_equal 23,Profile.count()
    prof=Profile.find(:first)

    prof=Profile.find(:first, :conditions=> ["name=?","PROF_1"]);
    assert_equal 251,prof.trace.min();
    assert_equal 750,prof.trace.max();
    prof=Profile.find(:first, :conditions=> ["name=?","PROF_5"]);
    assert_equal 750,prof.trace.max();
    assert_equal -1745,prof.trace.min();
  end
  def test_build_trace
     #Only two points
     trace_vals=[0,40]
     trace_freqs=[ 5_000_000,
                  50_000_000]
     built_trace=Profile.build_trace(trace_vals, trace_freqs)
     assert_equal 500,built_trace.length
     assert_in_delta 20.0,built_trace.sum/500,0.0001
     #five points
     trace_vals=[0,10,20,30,40]
     trace_freqs=[ 5_000_000,
                  16_250_000,
                  27_500_000,
                  38_750_000,
                  50_000_000]
     built_trace=Profile.build_trace(trace_vals, trace_freqs)
     assert_equal 500,built_trace.length
     assert_in_delta 20.0,built_trace.sum/500,0.0001

     #two points, but they do not start on edge
     trace_vals=[0,40]
     trace_freqs=[ 15_000_000,
                  35_000_000]
     built_trace=Profile.build_trace(trace_vals, trace_freqs)
     assert_equal 500,built_trace.length
     assert_in_delta 36.658,built_trace.sum/500,0.1
     #Mapping an array that is bursty
     trace_vals= [10,       15,       20,       25,       30,
                  35,       40,       30,       20]
     trace_freqs=[6_000_000,6_100_000,6_200_000, 6_950_000, 7_000_000,
                  8_000_000,9_000_000,10_000_000,50_000_000            ]
     built_trace=Profile.build_trace(trace_vals, trace_freqs)
     assert_equal 500,built_trace.length
     assert_in_delta 26.190,built_trace.sum/500,0.1
  end
end
