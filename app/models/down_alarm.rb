require 'instr_utils'
class DownAlarm < ActiveRecord::Base
  belongs_to :site
  belongs_to :measure
  belongs_to :channel
  validates_inclusion_of :alarm_type, :in =>1..2
  #  validates_format_of :email,
  #    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
  #    :if => Proc.new { |alarm| alarm.email.length > 0}

  after_create :send_email

  Major=1
  Minor=2
  TRAP_SET_Performance=1
  TRAP_CLEAR_performance=2
  def send_email
    alarm = DownAlarm.find(self.id)
	alarm_site = Site.find(alarm.site_id)
    unless alarm.email.nil? || alarm.email.empty?
      puts "Sending email for alarm #{alarm.id}"
      require 'pp'
      begin
        m = AlarmMailer.create_performance_alarm(alarm, alarm.email)
        AlarmMailer.deliver(m)
      rescue
        SystemLog.log("Alarm Email Failed, Email Setting Error, Please check corresponding setting","SMTP or EMAIL Setting Error occur.",SystemLog::MESSAGE,alarm_site.analyzer.id)
      end
    else
      puts "NOT Sending email for alarm #{alarm.id}"
    end
  end
  def DownAlarm.unack_act
    return 'a'
  end
  def DownAlarm.unack_inact
    return 'e'
  end
  def DownAlarm.ack_inact
    return 'i'
  end
  def DownAlarm.warn()
    return Minor
  end
  def DownAlarm.error()
    return Major
  end
  def DownAlarm.getActive(site_id, measure_id, channel_id)
    da=DownAlarm.find(:first, :conditions=>["active=1 and site_id=? and channel_id=? and measure_id=?", site_id, channel_id, measure_id])
    return da
  end
  def DownAlarm.deactivate(site_id, measure_id=nil, channel_id=nil, channel_type=nil)
    #Should only be one alarm but let's just be sure
    cond_str="site_id=?"
    cond_values=[site_id]
    if (!measure_id.nil?)
      cond_str += " and measure_id=?"
      cond_values.push(measure_id)
    end
    if (!channel_id.nil?)
      cond_str += " and channel_id=?"
      cond_values.push(channel_id)
    end
    cond=cond_values
    cond.unshift(cond_str)
    da_list=DownAlarm.find(:all, :conditions=>cond)
    da_list.each { |da|
      da[:active]=false
      da.save
    }
	  da2=DownAlarm.find(:all, :conditions=>cond,:limit=>1)
    if (measure_id.nil? || channel_type.nil? || channel_id.nil? || da2.empty?)
      return
    end
	  da1=da2[0]
    measure_name =Measure.find(measure_id).measure_name
    counter=ConfigParam.increment("SNMP Sequence Counter")
    site=Site.find(site_id)
    anl=site.analyzer
    if !anl.nil? && anl.snmp_active
      snmp_mgr_list=ConfigParam.find(:all, :conditions=>{:category=>"SNMP"})
      snmp_mgr_list.each {|snmp_mgr|
        if snmp_mgr.val.length > 0
          channel=Channel.find(channel_id)
          measure=Measure.find(measure_id)
          limit= da1[:min_limit].nil? ? da1[:max_limit] : da1[:min_limit]
          #InstrumentUtils.snmp_restore(snmp_mgr.val,counter,channel_type,  Time.now().to_s)
          port_name = site.analyzer_port.nil? ? "no port" : site.analyzer_port.name
          local_ip=`ifconfig`.slice(/[\d|.]+  Bcast/).sub(/  Bcast/,'')
          Avantron::InstrumentUtils.snmp_alarm_lvk(TRAP_CLEAR_performance,snmp_mgr.val,counter,site.name,port_name,Time.now().to_s,channel.channel_name,limit.to_s,measure.measure_name,da1.val.to_s,da1[:id].to_s,channel_type, da1.level_txt,"Alarm on #{measure_name}","http://#{local_ip}/measurement?siteid=#{da1[:site_id]}&start_date=#{da1[:event_time]}&stop_date=#{da1[:end_time]}&channel_id=#{da1[:channel_id]}&meas_id=#{da1[:measure_id]}")
          logger.debug "Down_stream SNMP Restore to #{snmp_mgr.val}"
        end
      }
    end
  end
  def DownAlarm.generate(site_id,external_temp,channel_id, measure_id,val,type,limit, channel_type)
    # Generate a down alarm. Actually this function will not
    # automatically create an alarm.  First it will check to see
    # if the alarm is active, and if so then it will modify
    # the existing alarm.
    site = Site.find(site_id)
    email=""
    if (!site.nil? &&  !site.analyzer.nil?)
      email=site.analyzer.email
    end
    active_alarm=DownAlarm.getActive(site_id, measure_id, channel_id)
    ts=DateTime.now()
    if (active_alarm.nil?)
      if (limit<val.to_f)
        da=DownAlarm.create(
          :site_id=>site_id,
          #:sf_test_plan_id=>test_plan_id,
          :external_temp =>external_temp,
          :channel_id => channel_id,
          :measure_id => measure_id,
          :val => val,
          :event_time=>ts,
          :end_time=>ts,
          :active=>1,
          :acknowledged=>false,
          :alarm_type=> type,
          :email => email,
          :max_limit=>limit
        )
      else
        da=DownAlarm.create(
          :site_id=>site_id,
          #:sf_test_plan_id=>test_plan_id,
          :external_temp =>external_temp,
          :channel_id => channel_id,
          :measure_id => measure_id,
          :val => val,
          :event_time=>ts,
          :end_time=>ts,
          :active=>1,
          :acknowledged=>false,
          :alarm_type=> type,
          :min_limit=>limit,
          :email => email
        )
      end
      level_type="Major"
      if DownAlarm.warn == type
        level_type="Minor"
      end
      measure_name =Measure.find(measure_id).measure_name
      site=Site.find(site_id)
      counter=ConfigParam.increment("SNMP Sequence Counter")
      anl=site.analyzer
      debugger
      if !anl.nil? && anl.snmp_active
        snmp_mgr_list=ConfigParam.find(:all, :conditions=>{:category=>"SNMP"})
        snmp_mgr_list.each {|snmp_mgr|
          if snmp_mgr.val.length > 0
            puts snmp_mgr.val
            channel=Channel.find(channel_id)
            measure=Measure.find(measure_id)
            #Avantron::InstrumentUtils.snmp_alarm(snmp_mgr.val,counter,channel_type, level_type, Time.now().to_s,"Alarm on #{measure_name}",site.name)
            port_name = site.analyzer_port.nil? ? "no port" : site.analyzer_port.name
            local_ip=`ifconfig`.slice(/[\d|.]+  Bcast/).sub(/  Bcast/,'')
            Avantron::InstrumentUtils.snmp_alarm_lvk(TRAP_SET_Performance,snmp_mgr.val,counter,site.name,port_name,Time.now().to_s,channel.channel_name,limit.to_s,measure.measure_name,val.to_s,da[:id].to_s,channel_type, level_type,"Alarm on #{measure_name}","http://#{local_ip}/measurement?siteid=#{da[:site_id]}&start_date=#{da[:event_time]}&stop_date=#{da[:end_time]}&channel_id=#{da[:channel_id]}&meas_id=#{da[:measure_id]}")
            logger.debug "down_stream SNMP Alarm to #{snmp_mgr.val}"
          end
        }
      end
      #logger.debug da.inspect()
    else
	  active_alarm[:alarm_type]=type
      active_alarm[:end_time]=ts
      active_alarm[:active]=1
      active_alarm.save
      #logger.debug active_alarm.inspect()
    end
    #logger.debug "Outside Generate"
  end
  def is_major?
    alarm_type == Major
  end
  def level_txt()
    if alarm_type == Major
      return "MAJOR"
    elsif alarm_type==Minor
      return "MINOR"
    else
      return "UNKNOWN"
    end
  end
  def DownAlarm.group_by_site(start_time, sort_by)
    query="select sites.id as id, sites.name as site_name,
      measures.measure_label as measure,
      measures.id as measure_id,
      down_alarms.alarm_type as typ,
      count(IF(active=1,1,NULL)) as active,
      count(IF((active is NULL) or (active =0),1,NULL)) as inactive,
      count(*) as cnt,
      max(event_time) as dt
      from down_alarms
      left join sites on sites.id=down_alarms.site_id
      left join measures on down_alarms.measure_id=measures.id
      where \"#{start_time}\" < event_time
      group by sites.id,measure_id,down_alarms.alarm_type"
    sort = case sort_by
    when "site"             then "site_name"
    when "type"             then "typ"
    when "measure"          then "measure"
    when "active"           then "active DESC"
    when "inactive"         then "inactive DESC"
    when "count"            then "cnt"
    when "recent"           then "dt"
    when "site_reverse"     then "site_name DESC"
    when "type_reverse"     then "typ DESC"
    when "measure_reverse"  then "measure DESC"
    when "active_reverse"   then "active"
    when "inactive_reverse" then "inactive"
    when "count_reverse"    then "cnt DESC"
    when "recent_reverse"   then "dt DESC"
    else "inactive desc"
    end
    query += " order by #{sort}"
    sql_results=Site.find_by_sql(query)
    return sql_results
  end
  def descr
    if !min_limit.nil?
      if measure.measure_name =~ /_lock/ && min_limit == 1 && val == 0
        return " #{measure.measure_label} Failed"
      elsif val < min_limit
        return "Min Limit error: #{val} < #{min_limit}"
      end
    end
    if !max_limit.nil?
      if val > max_limit
        return "Max Limit error: #{val} > #{max_limit}"
      end
    end
  end
  def DownAlarm.summarize(days)
    #Summarize by day all alarms after 'days'
    dt=Date.today
    target_dt=dt-days
    count = DownAlarm.count(:conditions => ['event_time < ?', target_dt.strftime('%F %T')])
    ids = DownAlarm.find(:all, :conditions => ['event_time < ?', target_dt.strftime('%F %T')]).collect {|alarm| alarm.id }
    DownAlarm.delete(ids)
  end
end
