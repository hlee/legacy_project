class Measure < ActiveRecord::Base
  has_many :measurements
  has_many :down_alarms
  def Measure::get_id(meas_name)
    Measure.connection.reconnect!()
    meas=Measure.find(:first,:conditions=>"measure_name='#{meas_name}'")
    if meas.nil?
      return nil
    end
    return meas
  end
  def Measure::alarmed()
    #If Alarmed measures then work just like Measure.find 
    #except throw away measures that do not have alarms
    meas_list= Measure.find(:all) 
    meas_list.collect!{|meas| 
      (meas.down_alarms.count > 0) ? meas : nil
    } 
    return meas_list.compact
  end
end
