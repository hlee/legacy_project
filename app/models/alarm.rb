require 'instr_utils'
class Alarm < ActiveRecord::Base
  belongs_to :site
  belongs_to :profile

  #  validates_format_of :email, 
  #    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
  #    :if => Proc.new { |alarm| alarm.email.length > 0}

  after_create :send_email

  include ImageFunctions
  Troubled=128
  DLAvg=11
  DLMax=10
  Loss=3
  Major=2
  Minor=1
  TRAP_SET_Ingress=3
  TRAP_CLEAR_Ingress=4
  def Alarm.minor
    return Minor
  end
  def Alarm.major
    return Major
  end
  def Alarm.loss
    return Loss
  end
  def send_email
    alarm = Alarm.find(self.id)
    alarm_site = Site.find(alarm.site_id)
    unless alarm.email.nil? || alarm.email.empty?
      begin
        m = AlarmMailer.create_ingress_alarm(alarm, alarm.email)
        AlarmMailer.deliver(m)
      rescue
        SystemLog.log("Alarm Email Failed, Email Setting Error, Please check corresponding setting","SMTP or EMAIL Setting Error occur.",SystemLog::MESSAGE,alarm_site.analyzer.id)
      end
    end
  end

  def image=(data)
    write_image(:image, data)
  end
  def image
    return read_image(:image)
  end
  def trace=(data)
    write_image(:trace, data)
  end
  def trace
    return read_image(:trace)
  end
  def Alarm.lvl_at2500_to_rwx(at2500_lvl)
    if at2500_lvl == 0 || at2500_lvl == 1
      return Minor
    elsif at2500_lvl == 2 || at2500_lvl == 3
      return Major
    elsif at2500_lvl == 4 
      return Loss
    else
    end
  end
  def is_minor?
    return alarm_type == Minor
  end
  def is_major?
    return alarm_type == Major
  end
  def is_loss?
    return alarm_type == Loss
  end
  def level_txt
    #Troubled alarms have alarm_type set to nil sometimes.
    result=""
    if alarm_type == Major
      result= "MAJOR"
    elsif alarm_type==Minor
      result= "MINOR"
    elsif alarm_type==Loss
      result= "Link Loss"
    else
      result="UNKNOWN [#{alarm_type}]"
    end
    if alarm_level >=128
      result=result + " (Trouble)"
    elsif alarm_type == DLMax
      p=Profile.find(profile_id)
      result=p.name+"(Datalog Profile)"
    elsif alarm_type == DLAvg
      p=Profile.find(profile_id)
      result="("+p.name+"(Datalog Profile)"
    end
    return result
  end
  def Alarm.group_by_site(start_time, sort_by)
    query="select sites.id as id, sites.name as site_name, 
      count(IF(active =1,1,NULL)) as active, 
      count(IF((active is NULL) or (active =0),1,NULL)) as inactive, 
      count(*) as cnt,
      max(event_time) as dt "+
      "from alarms left join sites " +
      "on sites.id=alarms.site_id " +
      "where \"#{start_time}\" < event_time " +
      "group by sites.id"
    sort = case sort_by
    when "site"             then "site_name"
    when "type"             then "typ"
    when "active"           then "active DESC"
    when "inactive"         then "inactive DESC"
    when "count"            then "cnt"
    when "recent"           then "dt"
    when "site_reverse"     then "site_name DESC"
    when "type_reverse"     then "typ DESC"
    when "active_reverse"   then "active"
    when "inactive_reverse" then "inactive"
    when "count_reverse"    then "cnt DESC"
    when "recent_reverse"   then "dt DESC"
    else "inactive desc"
    end
    query += " order by #{sort}"
    sql_results = Site.find_by_sql(query)
    return sql_results
  end
  def Alarm.deactivate(site_id)
    alarm_list = Alarm.find(:all, :conditions=>["active=? and site_id=?",1, site_id])
    unless alarm_list.empty?	
      alarm_list.each { |alarm|
        alarm[:active] = 0
        alarm.save
        counter   = ConfigParam.increment("SNMP Sequence Counter")
        analyzer  = Site.find(site_id).analyzer
        if !analyzer.nil? && analyzer.snmp_active
          snmp_mgr_list = ConfigParam.find(:all, :conditions=>{:category=>"SNMP"})
          snmp_mgr_list.each {|snmp_mgr|
            if snmp_mgr.val.length > 0
              #            InstrumentUtils.snmp_restore(snmp_mgr.val,counter,"Ingress",  Time.now().to_s)
              site=Site.find(site_id)
              local_ip=`ifconfig`.slice(/[\d|.]+  Bcast/).sub(/  Bcast/,'')
              Avantron::InstrumentUtils.snmp_alarm_lvk(TRAP_CLEAR_Ingress,snmp_mgr.val,counter,site.name,site.analyzer_port.name,Time.now().to_s,"","","","",alarm[:id].to_s,"Ingress",alarm.level_txt,"Ingress Alarm","http://#{local_ip}/livetrace?siteid=#{alarm[:site_id]}")

              logger.debug "SNMP Restore to #{snmp_mgr.val}"
            end
          }
        end
      }
    end
  end
  def Alarm.generate(alarm_info)
    alarm_info['active']=true
    if ((alarm_info[:alarm_type] == DLAvg) || (alarm_info[:alarm_type] == DLMax))
      alarm_info[:active]=0
    else
      alarm=Alarm.find(:first, 
        :conditions=>["site_id=? and active=TRUE",alarm_info[:site_id]])
      if (!alarm.nil?)
        Alarm.deactivate(alarm_info[:site_id])
      end
      alarm_info[:active]=1
    end
    alarm_info[:end_time]=alarm_info[:event_time]
    alarm = Alarm.create(alarm_info)
    unless alarm.profile.nil?
      alarm.major_offset = alarm.profile.major_offset
      alarm.minor_offset = alarm.profile.minor_offset
      alarm.loss_offset = alarm.profile.loss_offset
      alarm.link_loss = alarm.profile.link_loss
      alarm.trace = alarm.profile.trace
      if ((alarm.alarm_level <= 132) && (alarm.alarm_level >= 127))
        if (alarm.alarm_level < 130)
          alarm.alarm_type  = Minor
        else
          alarm.alarm_type  = Major
        end
      end
      #$logger.debug "ALARM Profile trace #{alarm.trace.inspect()}"
      alarm.save
      #$logger.debug "ALARM Profile trace RELOADED #{Alarm.find(:first).trace.inspect()}"
        
    end #END UNLESS
    site_obj = Site.find(alarm_info[:site_id].to_i)
    site_name = site_obj.name
    counter = ConfigParam.increment("SNMP Sequence Counter")
    analyzer = site_obj.analyzer
    if !analyzer.nil? && analyzer.snmp_active
      snmp_mgr_list=ConfigParam.find(:all, :conditions=>{:category=>"SNMP"})
      snmp_mgr_list.each {|snmp_mgr|
        if snmp_mgr.val.length > 0
=begin            Avantron::InstrumentUtils.snmp_alarm(snmp_mgr.val,
              counter,"Ingress", alarm.level_txt, 
              Time.now.to_s,"Ingress Alarm",site_name)
=end
          local_ip=`ifconfig`.slice(/[\d|.]+  Bcast/).sub(/  Bcast/,'')
          port_name = site_obj.analyzer_port.nil? ? "no port" : site_obj.analyzer_port.name
          Avantron::InstrumentUtils.snmp_alarm_lvk(TRAP_SET_Ingress,snmp_mgr.val,counter,site_name,port_name,Time.now().to_s,"","","","",alarm[:id].to_s,"Ingress",alarm.level_txt,"Ingress Alarm","http://#{local_ip}/livetrace?siteid=#{alarm_info[:site_id]}")
          logger.debug "SNMP Alarm to #{snmp_mgr.val}"
        end
      }
    end
    return alarm
  end
  def Alarm.summarize(days) 
    #Summarize by day all alarms after 'days'
    dt=Date.today
    target_dt=dt-days
    count = Alarm.count(:conditions => ['event_time < ?', target_dt.strftime('%F %T')])
    ids = Alarm.find(:all, :conditions => ['event_time < ?', target_dt.strftime('%F %T')]).collect {|alarm| alarm.id }
    Alarm.delete(ids)
  end
end
