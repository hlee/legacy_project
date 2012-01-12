require File.dirname(__FILE__) + '/../test_helper'

class DatalogTest < Test::Unit::TestCase
  fixtures :datalogs, :config_params

  def setup
     start=ConfigParam.find_by_name("Start Frequency")
     start.val=5000000
     start.save
     stop=ConfigParam.find_by_name("Stop Frequency")
     stop.val=50000000
     stop.save
     #Datalog.delete_all()
     20.times { |index|
        dl=Datalog.new()
        dl.ts=Time.gm(2006,"jan",index+1,12,0,0)
        #dl.rptp=1
        image_arr=[]
        max_arr=[]
        min_arr=[]
        dl.site_id=1
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
        dl.start_freq=5000000
        dl.stop_freq= 50000000
        dl.save()
        dl.store_images(min_arr, image_arr, max_arr)
     }
     #Let's build some test data 
  end
  def summarize_setup
     Datalog.delete_all()
     start=ConfigParam.find_by_name("Start Frequency")
     start.val=5000000
     start.save
     stop=ConfigParam.find_by_name("Stop Frequency")
     stop.val=50000000
     stop.save
     #Datalog.delete_all()
     now=Time.now
     orig=today=Time.gm(now.year,now.mon,now.day)
     1500.times { |index|
        secs=(index*3600)
        dl=Datalog.new()
        dl.ts=orig-secs
        #dl.rptp=1
        image_arr=[]
        max_arr=[]
        min_arr=[]
        dl.site_id=1
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
        dl.start_freq=5000000
        dl.stop_freq= 50000000
        dl.save()
        dl.store_images(min_arr, image_arr, max_arr)
     }
     #Let's build some test data 
  end

  # Replace this with your real tests.
  def test_datalog_build
    assert_equal 26,Datalog.count()
  end
  def deact_test_diff_image
     diff=ImageFunctions.diff_image([10,9,8,7],[4,4,4,4])
     assert_equal 6,diff.max
     assert_equal 3,diff.min
     assert_equal 4,diff.length
     assert_equal 5,diff[1]
     assert_equal 4,diff[2]

     diff=ImageFunctions.diff_image(nil,[4,4,4,4])
     assert_equal -4,diff.max
     assert_equal -4,diff.min
     assert_equal 4,diff.length

     diff=ImageFunctions.diff_image([10,9,8,7],nil)
     assert_equal 10,diff.max
     assert_equal 7,diff.min
     assert_equal 4,diff.length

     diff=ImageFunctions.diff_image([10,9,8,7],[4,4,4,nil])
     assert_equal 7,diff.max
     assert_equal 4,diff.min
     assert_equal 4,diff.length
     assert_equal 5,diff[1]
     assert_equal 4,diff[2]
     assert_equal 7,diff[3]

  end
  def deact_test_power_image
     diff=ImageFunctions.power_image([10,9,8,7],1)
     assert_equal 10,diff.max
     assert_equal 7,diff.min
     assert_equal 4,diff.length
     assert_equal 9,diff[1]
     assert_equal 8,diff[2]

     diff=ImageFunctions.power_image([10,9,8,7],2)
     assert_equal 100,diff.max
     assert_equal 49,diff.min
     assert_equal 4,diff.length
     assert_equal 81,diff[1]
     assert_equal 64,diff[2]

     diff=ImageFunctions.power_image([6.25,2.25,1,0.25],0.5)
     assert_equal 2.5,diff.max
     assert_equal 0.5,diff.min
     assert_equal 4,diff.length
     assert_equal 1.5,diff[1]
     assert_equal 1,diff[2]

     diff=ImageFunctions.power_image([6.25,nil,1,0.25],0.5)
     assert_equal 2.5,diff.max
     assert_equal 0,diff.min
     assert_equal 4,diff.length
     assert_equal 0,diff[1]
     assert_equal 1,diff[2]
     assert_equal 0.5,diff[3]


  end
=begin
  #{:site_id=>0,:start_ts=>0,:stop_ts=>0,:start_freq=>1000,:stop_freq=>0}
  def test_summarize_datalogs
     assert_raises(RangeNotSet) do
        Datalog.summarize_datalogs({})
     end
     assert_raises(RangeNotSet) do
        Datalog.summarize_datalogs({:site_id=>0,:start_ts=>0,
           :stop_ts=>0,:start_freq=>0,:stop_freq=>nil})
     end
     assert_raises(RangeNotSet) do
       Datalog.summarize_datalogs({:site_id=>0,:start_ts=>0,
        :stop_ts=>0,:start_freq=>nil,:stop_freq=>0})
     end
     assert_raises(RangeNotSet) do
       Datalog.summarize_datalogs({:site_id=>0,:start_ts=>0,
         :stop_ts=>nil,:start_freq=>0,:stop_freq=>0})
     end
     assert_raises(RangeNotSet) do
        Datalog.summarize_datalogs({:site_id=>nil,:start_ts=>0,
           :stop_ts=>0,:start_freq=>0,:stop_freq=>0})
     end
     assert_raises(RangeNotSet) do
        Datalog.summarize_datalogs({:site_id=>0,:start_ts=>nil,
           :stop_ts=>0,:start_freq=>0,:stop_freq=>0})
     end
     result=Datalog.summarize_datalogs({:site_id=>1, 
       :start_ts=>Time.utc(2006,1,1,11,59,00),
       :stop_ts=>Time.utc(2006,1,1,12,59,00),
       :start_freq=>0,:stop_freq=>2000})
       assert_equal 0,result[:min].length
       assert_equal 0,result[:max].length
       assert_equal 0,result[:total].length

     result=Datalog.summarize_datalogs({:site_id=>1, 
       :start_ts=>Time.utc(2006,1,1,11,59,00),
       :stop_ts=>Time.utc(2006,1,5,12,59,00),
       :start_freq=>5000000,:stop_freq=>50000000})
     assert_equal 750,result[:avg].max
     assert_equal 745,result[:avg].min,"#{result.inspect()}"
     assert_equal 5,result[:avg].length
     assert_equal 5,result[:avg].length
     assert_equal 400,result[:min].max
     assert_equal 380,result[:min].min
     assert_equal 5,result[:min].length
     assert_equal 820,result[:max].max
     assert_equal 800,result[:max].min
     assert_equal 5,result[:max].length
     #assert_equal 375000,result[:total].max
     #assert_equal 372750,result[:total].min
     #assert_equal 5,result[:total].length
     result=Datalog.summarize_datalogs({:site_id=>1, 
       :start_ts=>Time.utc(2006,1,1,11,59,00),
       :stop_ts=>Time.utc(2006,1,5,12,59,00),
       :start_freq=>5000000,:stop_freq=>50000000},false)
     assert_in_delta 745.6,result[:avg].min,0.1
     assert_equal 500,result[:avg].length
     assert_equal 380,result[:min].max
     assert_equal 380,result[:min].min
     assert_equal 500,result[:min].length
     assert_equal 820,result[:max].max
     assert_equal 820,result[:max].min
     assert_equal 500,result[:max].length
     #assert_equal 3750,result[:total].max
     #assert_equal 3728,result[:total].min
     #assert_equal 500,result[:total].length
     assert_equal 5000000,result[:min_freq]
     assert_equal 50000000,result[:max_freq]
     #assert_equal 500,result[:stdev].length
     #assert_in_delta 3.6469,result[:stdev].max(),0.0001
     #assert_equal 0,result[:stdev].min()
     result=Datalog.summarize_datalogs({:site_id=>1, 
       :start_ts=>Time.utc(2006,1,1,11,59,00),
       :stop_ts=>Time.utc(2006,1,5,12,59,00),
       :start_freq=>5000000,:stop_freq=>30000000},false)
       #assert_equal 3750,result[:total].max
       #assert_equal 3738,result[:total].min
       #assert_equal 278,result[:total].length
     assert_equal 278,result[:avg].length
     assert_in_delta 747.6,result[:avg].min,0.1
     assert_equal 750,result[:avg].max
     assert_equal 380,result[:min].max
     assert_equal 380,result[:min].min
     assert_equal 278,result[:min].length
     assert_equal 820,result[:max].max
     assert_equal 820,result[:max].min
     assert_equal 278,result[:max].length
     assert_equal 5_000_000,result[:min_freq]
     assert_equal 29979960,result[:max_freq]
     #assert_equal 278,result[:stdev].length
     #assert_in_delta 2.07364,result[:stdev].max(),0.0001
     #assert_equal 0,result[:stdev].min()
     result=Datalog.summarize_datalogs({:site_id=>1, 
       :start_ts=>Time.utc(2006,1,1,11,59,00),
       :stop_ts=>Time.utc(2006,1,5,12,59,00),
       :start_freq=>10_000_000,:stop_freq=>90_000_000},false)
       #assert_equal 3749,result[:total].max
       #assert_equal 3728,result[:total].min
       #assert_equal 444,result[:total].length
     assert_equal 444,result[:avg].length
     assert_in_delta 745.6,result[:avg].min,0.1
     assert_in_delta 749.8,result[:avg].max,0.1
     assert_equal 380,result[:min].max
     assert_equal 380,result[:min].min
     assert_equal 444,result[:min].length
     assert_equal 820,result[:max].max
     assert_equal 820,result[:max].min
     assert_equal 444,result[:max].length
     assert_equal 10050100.0,result[:min_freq]
     assert_equal 50000000,result[:max_freq]
     assert_equal 10050100,result[:freq].min
     assert_equal 50000000,result[:freq].max
     assert_equal 13331122245,result[:freq].sum
     #assert_equal 444,result[:stdev].length
     #assert_in_delta 3.6469,result[:stdev].max(),0.0001
     #assert_in_delta 0.4472,result[:stdev].min(),0.0001
     #assert_equal Time.new("Sun Jan 01 12:00:00 -0500 2006"),result[:min_ts]
     #assert_equal 500,result[:max_ts]

  end
=end
  def test_map_data
     input_data=[5.0,7.0,9.0,11.0,13.0,15.0]
     #Map to equivalent
     mapped_data=Datalog.map_data(5,15,5,15,input_data,6)
     expected_data=[5.0,7.0,9.0,11.0,13.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to equivalent"
     #Map to higher detail
     mapped_data=Datalog.map_data(5,15,5,15,input_data,11)
     expected_data=[5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
     #Map to lower detail
     mapped_data=Datalog.map_data(5,15,5,15,[5,7,9,11,13,15,17],4)
     expected_data=[5.0,9.0,13.0,17.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to lower detail"
     #Map equivalent to left
     mapped_data=Datalog.map_data(5,15,3,13,input_data,6)
     expected_data=[5.0,5.0,7.0,9.0,11.0,13.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the left"
     #Map equivalent to right
     mapped_data=Datalog.map_data(5,15,7,17,input_data,6)
     expected_data=[7.0,9.0,11.0,13.0,15.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the right"
     #Map from 2point to multipoint
     mapped_data=Datalog.map_data(5,15,5,15,[5,15],11)
     expected_data=[5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
     #Extend past boundries
     mapped_data=Datalog.map_data(5,15,3,17,input_data,8)
     expected_data=[5.0,5.0,7.0,9.0,11.0,13.0,15.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the right"
     #Non Linear Data
     input_data=[5.0,6.0,5.0,1.0,0.0,5.0]
     #Map to equivalent
     mapped_data=Datalog.map_data(5,15,5,15,input_data,6)
     expected_data=input_data
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to equivalent"
     #Map to higher detail
     mapped_data=Datalog.map_data(5,15,5,15,input_data,11)
     expected_data=[5.0,5.5,6.0,5.5,5.0,3.0,1.0,0.5,0.0,2.5,5.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
  end
  def test_compress_data
    ts=Time.gm(2007,1,1,1,0,0)
    dates=[ts+0,ts+60,ts+120,ts+180,ts+240, ts+300]
    initial_data={:min=>[1,2,3,4,5,6],:max=>[10,20,30,40,50,60],:avg=>[5,10,15,20,25,30],:time=>dates}
    result=Datalog.compress_overtime(initial_data,50)
    assert initial_data[:min].sum == result[:min].sum
    assert initial_data[:max].sum == result[:max].sum
    assert initial_data[:avg].sum == result[:avg].sum
    assert initial_data[:time][0] == result[:time][0]
    assert initial_data[:time][2] == result[:time][2]
    assert initial_data[:time][3] == result[:time][3]
    result=Datalog.compress_overtime({:min=>[1,2,3,4,5,6],:max=>[10,20,30,40,50,60],:avg=>[5,10,15,20,25,30],:time=>dates},3)
    assert result[:min].sum == 7
    assert result[:max].sum == 100
    assert result[:avg].sum == 42
    assert dates[0] == result[:time][0]
    assert dates[5] == result[:time][2]
    dates=[ts+0,ts+60,ts+420,ts+480,ts+540, ts+600]
    result=Datalog.compress_overtime({:min=>[1,2,3,4,5,6],:max=>[10,20,30,40,50,60],:avg=>[5,10,15,20,25,30],:time=>dates},5)
    assert result[:min].sum == 12
    assert result[:max].sum == 140, "expected 140, got #{result[:max].sum}"
    assert result[:avg].sum == 65, "expected 65, got #{result[:avg].sum}"
    assert dates[0] == result[:time][0]
    assert dates[5] == result[:time][4]
  end
  def test_summarize
    summarize_setup
    Datalog.summarize(30)
    list=Datalog.find(:all, :conditions => "sample_count > 50", :order=>"ts desc")
    #list.each { |dat|
      #puts "#{dat.site_id}, #{dat.ts} , #{dat.sample_count},  #{dat.start_freq}, #{dat.stop_freq}, #{dat.min_val},#{dat.max_val}, #{dat.val}"
    #}
    assert 33, list.length
    assert 1200, list[0].sample_count
    assert 150, list[32].sample_count
    assert -3360, list[0].min_val
    assert 4560, list[0].max_val
    assert -173.75, list[0].val
  end

end
