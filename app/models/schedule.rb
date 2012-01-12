class Schedule < ActiveRecord::Base
  has_many :scheduled_sources, :order => "order_nbr", :dependent => :destroy 
  has_many :switch_ports, :through =>:scheduled_sources
  belongs_to :analyzer

  def return_port_schedule
    return scheduled_sources.select { |elem| elem.switch_port.is_return_path?}
  end
  def validate
    errors.add(acquisition_count, "Acquisition count must be >= 1") unless acquisition_count.to_i >= 1
    errors.add(trace_polling_period, "Trace Polling Period must be > 1") unless trace_polling_period.to_i > 1
  end
  def Schedule.verify(analyzer_id) 
    #Returns a string. If it passes all the tests then return a nil
    schedule=Schedule.find(:first, :conditions => ["analyzer_id=?", analyzer_id])
    return schedule.verify_scheduled_ports()
  end
  def verify_scheduled_ports
#    if (scheduled_sources.count() == 0)
#      errors.add_to_base("No ports scheduled")
#      return false
#    end
    scheduled_sources().each { |src|
      swp=SwitchPort.find(src.switch_port_id)
      if swp.nil?
        errors.add_to_base("Schedule needs to be re-initialized. {SwitchPort}")
        return false
      end
      if swp.switch.nil?
        errors.add_to_base("Schedule needs to be re-initialized. {Switch}")
        return false
      end
      if swp.switch.analyzer.nil?
        errors.add_to_base("Schedule needs to be re-initialized. {Analyzer}")
        return false
      end
      analyzer_id= swp.switch.analyzer_id
      if analyzer_id != analyzer.id
        errors.add_to_base("Switch ports change, re-init schedule")
        return false
      end
    }
    return true
  end
  def init_schedule_dtls()
    analyzer=self.analyzer
    if analyzer.nil?
      raise "No Analyzer associated with schedule"
    end
    switch_list=analyzer.switches
    schedule_id=self.id
    order_nbr=0
    analyzer.switches.each { |switch|
      SwitchPort.find(:all,:conditions=>"switch_id=#{switch.id}",:order=>"name").each { |switch_port|
        if (!switch_port.get_calculated_port().nil?)
          calculated_port=switch_port.get_calculated_port().to_s
          sched_src=ScheduledSource.new({
            :schedule_id=>schedule_id,
            :switch_port_id=>switch_port.id,
            :stat_trace_flag=>1, 
            :integral_trace_flag=>1,
            :order_nbr=>order_nbr
          })
          sched_src.save()
          order_nbr=order_nbr+100
        end
      }
    }
  end
end
