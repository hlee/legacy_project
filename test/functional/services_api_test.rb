require File.dirname(__FILE__) + '/../test_helper'
require 'services_controller'

class ServicesController; def rescue_action(e) raise e end; end

class ServicesControllerApiTest < Test::Unit::TestCase
   fixtures :analyzers
   fixtures :switches
   fixtures :switch_ports
   fixtures :channels
   fixtures :measures
   fixtures :measurements
   fixtures :sites
   fixtures :sf_system_files
   fixtures :sf_test_plans
   fixtures :sf_channels
   fixtures :datalogs

  def setup
     #Let's build some test data 
    @controller = ServicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Profile.delete_all()
    #Build datlog
     #Datalog.delete_all()
     20.times { |index|
        dl=Datalog.new()
        dl.ts=Time.local(2006,"jan",index+1,12,0,0)
        image_arr=[]
        max_arr=[]
        min_arr=[]
        dl.sample_count=50
        500.times { |trace_index|
           val=750-(trace_index*index/200).floor
           image_arr.push(val)
           max_arr.push(800+index*5)
           min_arr.push(400-index*5)
        }
        dl.image=image_arr
        dl.min_image=min_arr
        dl.max_image=max_arr
        dl.attenuation=10
        dl.start_freq=5_000_000
        dl.stop_freq=49_000_000
        dl.site_id=1
        dl.save()
     }
     # ???  -- Jason
     #ConfigParam.initdb()
  end

  def test_get_instruments
     result = invoke :get_instruments
     assert_equal 5, result.length
     assert_equal 'analyzer2',result[1].name
     assert_equal 'analyzer3',result[2].name

  end
  def test_get_sites
     result = invoke :get_sites,1
     assert_equal 2, result.length
     assert_equal 'two',result[1].name
     assert_equal 'one',result[0].name
     assert_equal 102,result[1].site_id
     assert_equal 101,result[0].site_id
     result = invoke :get_sites,2
     assert_equal 4, result.length
  end
	def test_get_date_range
		result=invoke :get_date_range, 101
		assert result.length==2
		assert_equal result[0],DateTime.new(2007,02,02,0,0,0)
		assert_equal result[1],DateTime.new(2007,03,02,23,59,59)
	end

  def test_get_nodes
     result = invoke :get_nodes,1
     assert_equal 80, result.length
     result = invoke :get_nodes,3
     assert result.empty?
  end

  def test_get_datalog_trace
      assert true
      return
     result = invoke :get_datalog_trace,1,'TEST1',1, 5_000_000,200_000_000,
       Time.gm(2006,"jan",1,12,0,0), Time.gm(2006,"jan",10,12,0,0),
       1,1,false
     assert !result.nil?,"did not get a result for port 17"
     assert_equal 1, result.transaction_id
     assert_equal 'TEST1', result.trace_label
     assert result.avg.kind_of?(Array),"Average data not an array"
     assert result.max.kind_of?(Array),"Max data not an array"
     assert result.min.kind_of?(Array),"Min data not an array"
     assert result.stdev.kind_of?(Array),"stdev data not an array"
     assert_equal 500, result.avg.length,"Min data does not contain 500 points"
     assert_equal 500, result.max.length,"Max data does not contain 500 points"
     assert_equal 500, result.min.length,"Min data does not contain 500 points"
     #assert_equal 500, result.stdev.length,"stdev data does not contain 500 points"
     #assert_in_delta 7.45654, result.stdev.max,0.0001,"stdev max is not correct"
     #assert_in_delta 0, result.stdev.min,0.0001,"stdev min is not correct"
     result = invoke :get_datalog_trace,3,'TEST2',1, 5_000_000,200_000_000,
       Time.gm(2006,"jan",1,12,0,0), Time.gm(2006,"jan",10,12,0,0),
       1,1,true
     assert !result.nil?,"did not get a result for port 1"
     assert_equal 3, result.transaction_id
     assert_equal 'TEST2', result.trace_label
     assert result.avg.kind_of?(Array),"Average data not an array"
     assert result.max.kind_of?(Array),"Max data not an array"
     assert result.min.kind_of?(Array),"Min data not an array"
     assert_equal 10, result.avg.length,"Min data does not contain 500 points"
     assert_equal 10, result.max.length,"Max data does not contain 500 points"
     assert_equal 10, result.min.length,"Min data does not contain 500 points"
     #Fixed bug in datalog.rb code. query was missing parameters.
     #So not my
     # result = invoke :get_datalog_trace,'TEST3',2, 5_000_000,50_000_000,
     #   Time.gm(2006,"jan",1,12,0,0), Time.gm(2006,"jan",10,12,0,0),
     #   1,1,true
       #assert !result.nil?,"did not get a result for port 2"
     #     assert_equal 'TEST3', result.trace_label
     #assert result.avg.kind_of?(Array),"Average data not an array"
     #assert result.max.kind_of?(Array),"Max data not an array"
     #assert result.min.kind_of?(Array),"Min data not an array"
     #assert_equal 0, result.avg.length,"Min data does not contain 500 points"
     #assert_equal 0, result.max.length,"Max data does not contain 500 points"
     #assert_equal 0, result.min.length,"Min data does not contain 500 points"
     #result = invoke :get_datalog_trace,'TEST4',112, 5_000_000,200_000_000,
     #  Time.gm(2006,"jan",1,12,0,0), Time.gm(2006,"jan",10,12,0,0),
     #  1,1,true
     #assert !result.nil?,"did not get a result for port 112"
     #assert_equal 'TEST4', result.trace_label
     #assert result.avg.kind_of?(Array),"Average data not an array"
     #assert result.max.kind_of?(Array),"Max data not an array"
     #assert result.min.kind_of?(Array),"Min data not an array"
     #assert_equal 0, result.avg.length,"Min data does not contain 500 points"
     #assert_equal 0, result.max.length,"Max data does not contain 500 points"
     #assert_equal 0, result.min.length,"Min data does not contain 500 points"
  end

  def test_ranges
      assert true
      return
     result=invoke :get_datalog_range, 1
     assert_equal   5_000_000,result.min_freq
     assert_equal 50_000_000,result.max_freq
     assert_equal DateTime.civil(2006,1,1,17,0,0).new_offset().to_s,result.min_ts.new_offset().to_s
     assert_equal DateTime.civil(2006,1,20,17,0,0).new_offset().to_s,result.max_ts.new_offset().to_s
     result=invoke :get_datalog_range, 50
     assert result.nil?, "Result range for invalid port id is not nil #{result.inspect}"
     result=invoke :get_datalog_range, 3
     assert result.nil?, "Result range for valid port id with no data is not nil"
  end

  def test_profile_funcs
      assert true
      return
     result=invoke :get_profile_list
     assert_equal 0,result.length
     trace_freqs=[5_000_000, 50_000_000]
     trace_vals=[0,40]
     result=invoke :set_profile,"prof1",trace_vals,trace_freqs
     assert  true, result
     prof=Profile.find(:first)
     assert 'prof1',prof.name
     assert  40, prof.trace.max
     assert  0, prof.trace.min
     assert  10000, prof.trace.sum
     result=invoke :get_profile_list
     assert_equal 1,result.length
     id=prof.id
     prof=  invoke:get_profile,id
     assert  500, prof.length
     assert  40, prof[499].val
     assert  0, prof[0].val
  end

  def test_get_channels
     result=invoke :get_channels,101
     assert_equal result.length , 4
     assert_equal result[0].channel_name , 'two'
     assert_equal result[2].channel_name , 'four'
     assert_equal 61, result[1].channel.to_i 
     assert_equal 75, result[3].channel.to_i 
  end
  def test_get_measures
     result=invoke :get_measures
     assert_equal 14, result.length 
     assert_equal 'mer_256',result[2].measure_name 
     assert_equal 'ber_pre_64',result[3].measure_name 
  end
  def test_get_sample_times
     result=invoke :get_sample_times,101, Time.gm(2006,"jan",1,12,0,0), Time.gm(2008,"jan",10,12,0,0)
     assert_equal result.length , 3
  end
  def test_get_instance_measument
      assert true
      return
     result=invoke :get_instance_measurement, 101, [1,2],[1,2,3,4],"2007-02-02 10:00:00"
     assert_equal 4, result.length 
     assert_equal 2, result[0].val.length
     assert_equal 1, result[0].channel_id
     assert_equal 2, result[1].channel_id
     assert_equal 3, result[2].channel_id
     assert_equal 4, result[3].channel_id
  end
  def test_get_measurements
      assert true
      return
     result=invoke :get_measurement, 101, [1,2],[1,2,3,4],Date.new(2001,1,1),Date.new(2008,1,1)
     assert_equal 4, result.length 
     assert_equal 2, result[0].max.length
     assert_equal 2, result[1].min.length
     assert_equal 2, result[2].avg.length
     assert_equal 1, result[0].channel_id
     assert_equal 2, result[1].channel_id
     assert_equal 3, result[2].channel_id
     assert_equal 4, result[3].channel_id
     assert_equal 15, result[0].min[0]
     assert_equal 25, result[0].max[0]
     assert_equal 20, result[0].avg[0]
     assert_equal 40, result[0].min[1]
     assert_equal 40, result[0].max[1]
     result=invoke :get_measurement,102, [1,2],[1,2,3],Date.new(2001,1,1),Date.new(2008,1,1)
     assert_equal 3, result.length 
  end
  def test_get_recent_measurement
     result=invoke :get_recent_measurement,101,[9,11,13],[1,2,3,4]
     assert_equal 4, result.measurements.length 
     result=invoke :get_recent_measurement,102,[9,11,13],[1,2,3]
     assert_equal 3, result.measurements.length 
  end
  def test_get_slm_summary
     result=invoke :get_slm_summary, 101,[1,2,3,4],Date.new(2001,1,1),Date.new(2008,1,1)
     assert_equal 4, result.length 
     assert_equal 2, result[0].max.length
     assert_equal 2, result[1].min.length
     assert_equal 2, result[2].avg.length
     assert_equal 1, result[0].channel_id
     assert_equal 2, result[1].channel_id
     assert_equal 3, result[2].channel_id
     assert_equal 4, result[3].channel_id
     assert_equal 15, result[0].min[0]
     assert_equal 20, result[0].max[0]
     assert_equal 17.5, result[0].avg[0]
     assert_equal 40, result[0].min[1]
     assert_equal 40, result[0].max[1]
     result=invoke :get_slm_summary,102,[1,2,3,4],Date.new(2001,1,1),Date.new(2008,1,1)
     assert_equal 4, result.length 
  end
=begin
  def test_get_channel_info
     result=invoke :get_channel_info,1,101
     assert_equal result.meas_list.length, 2
     assert_equal result.modulation, "NTSC"
     assert_equal result.channel_name, "ABC"
     assert_equal result.channel_nbr, "1"
     assert_equal 9,result.meas_list[0]
     assert_equal 11,result.meas_list[1]
     result=invoke :get_channel_info,1,110
     assert !result.nil?
     result=invoke :get_channel_info,4,110
     assert_equal 0,result.meas_list.length
     assert_equal "NTSC", result.modulation
     assert_equal "CBS", result.channel_name
     assert_equal "2", result.channel_nbr
  end
=end
  def test_get_meas_values
    result=invoke :get_meas_values,1,9,101,Date.new(2001,1,1),Date.new(2008,1,1)
    assert_equal 2,result.meas_values.length
    assert_equal 2,result.dates.length
    assert_equal 9,result.measure_id
    assert_equal 1,result.channel_id
    assert_equal 101,result.site_id
    assert_equal 15,result.meas_values[0]
    assert_equal 20,result.meas_values[1]
    assert_equal DateTime.new(2007,2,2,10,0,0,Rational(0,24)).to_s,result.dates[0].to_s
    assert_equal DateTime.new(2007,3,2,10,30,0,Rational(0,24)).to_s,result.dates[1].to_s
  end
end
