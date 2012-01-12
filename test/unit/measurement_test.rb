require File.dirname(__FILE__) + '/../test_helper'

class MeasurementTest < Test::Unit::TestCase
  fixtures :channels, :measures,:sites,:measurements
  def setup
    fields=[:channel_id, :measure_id, :site_id, :value, :min_value, :max_value, :min_limit, :max_limit,:dt]
    data=[]
    now=Time.now
    today=Time.gm(now.year,now.mon,now.day)
    channel=Channel.find(:first) 
      [2].each { |measure_id|
        [101,102].each { |site_id|
          1500.times { |hours|
            secs=hours*3600
            t=today-secs
            data.push([channel.id, measure_id, site_id, hours,nil,nil,10,1,t.strftime('%F %T')])
            
          }
        }
      }

    cnt=data.length
    Measurement.import fields, data
  end
  # Replace this with your real tests.
  def test_summarize
    
    #assert_equal 3000,Measurement.find(:all, :conditions => "sum_count is null",:order=>"dt desc").length
    vals=Measurement.summarize(30)
    recs=Measurement.find(:all,:conditions => "sum_count is not null", :order=>"dt desc")
    #recs.each { |rec|
    #  puts " #{rec.dt}, #{rec.sum_count}, #{rec.value}, #{rec.min_value},#{rec.max_value}"
    #}
    assert_equal 66,recs.length
    assert_equal 732.5,recs[0].value
    assert_equal 744,recs[0].max_value
    assert_equal 721,recs[0].min_value
    assert_equal 756.5,recs[2].value
    assert_equal 768,recs[2].max_value
    assert_equal 745,recs[2].min_value
    #puts vals.inspect()
  end
  def test_get_recent
    meas_list=Measurement.get_recent(101,[9,11],[1,3,4])
    assert_equal 6,meas_list.length
    vals=[]
    meas_list.collect { |v|
      vals.push(v.id)
    }
    assert vals.include?(15)
    assert vals.include?(5)
    assert vals.include?(3)
    assert vals.include?(7)
    assert vals.include?(4)
    assert vals.include?(8)
  end
end
