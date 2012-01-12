#!/usr/bin/ruby 

require 'net/telnet'
require 'snmp'
class SNMP_Error < StandardError
end
module Avantron
include SNMP
class InstrumentUtils
  def InstrumentUtils.reset(ip)
    analyzer=Net::Telnet::new('Host' => ip)
    analyzer.waitfor(/Enter password:/)
    txt=analyzer.cmd('galopin')
    if txt !~ /~ #/
      raise "Unable to login"
    end
#    txt=analyzer.cmd('cd /usr/local/bin/atsoft')
#    if txt !~ /(\/usr\/local\/bin\/atsoft #)/
#      raise "Unable to cd"
#    end
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor.pos', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor.ref', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor.sch', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor.sig', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor.swt', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/data_logging/*', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/debug/*', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
#    txt=analyzer.cmd('String'=>'rm /usr/local/bin/atsoft/monitor/*', 'Match'=>/\/usr\/local\/bin\/atsoft #/)
    txt=analyzer.cmd('String'=>'reboot', 'Match'=>'/usr/local/bin/atsoft #')
  end
  def InstrumentUtils.validate_alarm_type(alarm_type)
    if alarm_type.nil?
      alarm_type="INGRESS"
    end
    case alarm_type.upcase
      when "INGRESS"
        return true
      when "ANALOG"
        return true
      when "DIGITAL"
        return true
      when "COMMUNICATION ERROR"
        return true
      else
        return false
    end
  end
  def InstrumentUtils.validate_alarm_level(alarm_level)
    if alarm_level.nil?
      alarm_level = "UNKNOWN"
    end
    case alarm_level.upcase
      when "MINOR"
        return true
      when "MAJOR"
        return true
      when "LINK LOSS"
        return true
      when "UNKNOWN"
        return true
      else
        return false
    end
  end
 
  def InstrumentUtils.snmp_alarm(manager, seq, alarm_type, alarm_lvl, utc_time, descr="", hardware="", 
     region="", operator="", element="", element_type="", location="", channel_name="")
    if !InstrumentUtils.validate_alarm_type(alarm_type)
      raise SNMP_Error.new("Alarm type [#{alarm_type}] not valid")
    end
    if !InstrumentUtils.validate_alarm_level(alarm_lvl)
      raise SNMP_Error.new("Alarm Level [#{alarm_lvl}] not valid")
    end
    var_binds= [
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.1",SNMP::Integer.new(seq)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.2",SNMP::OctetString.new(alarm_type)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.3",SNMP::OctetString.new(alarm_lvl)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.4",SNMP::OctetString.new(utc_time)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.5",SNMP::OctetString.new(descr)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.6",SNMP::OctetString.new(hardware)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.7",SNMP::OctetString.new(region)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.8",SNMP::OctetString.new(operator)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.9",SNMP::OctetString.new(element)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.10",SNMP::OctetString.new(element_type)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.11",SNMP::OctetString.new(location))
         ]
      if channel_name.length > 0
         var_binds.push(SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.12",SNMP::OctetString.new(channel_name)))
      end
      SNMP::Manager.open(:Host => manager,:Version => :SNMPv1) do |snmp|
        snmp.trap_v1(
          "enterprises.10300.1.1.6",
          manager,
          :enterpriseSpecific, #Generic Trap Type
          1, #Trap Type
          12345,
          var_binds
        )
    end
  end
	
  def InstrumentUtils.snmp_alarm_lvk(trap_type,manager, seq, site_name,port_name,start_time,channel="",threshold="",measure="", current_value="", alarm_id="",alarm_type="",alarm_lvl="", descr="",trace_url="")
    unless alarm_type.nil?
    
    if !InstrumentUtils.validate_alarm_type(alarm_type)
      raise SNMP_Error.new("Alarm type [#{alarm_type}] not valid")
    end
    end
    unless alarm_lvl.nil?
    if !InstrumentUtils.validate_alarm_level(alarm_lvl.gsub!(/ \(Trouble\)/,''))
      raise SNMP_Error.new("Alarm Level [#{alarm_lvl}] not valid")
    end
    end
    var_binds= [
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.1",SNMP::Integer.new(seq)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.2",SNMP::OctetString.new(site_name)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.3",SNMP::OctetString.new(port_name)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.4",SNMP::OctetString.new(start_time)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.5",SNMP::OctetString.new(channel)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.6",SNMP::OctetString.new(threshold)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.7",SNMP::OctetString.new(measure)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.8",SNMP::OctetString.new(current_value)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.9",SNMP::OctetString.new(alarm_id)),
		  SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.10",SNMP::OctetString.new(alarm_type)),
		  SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.11",SNMP::OctetString.new(alarm_lvl)),
		  SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.12",SNMP::OctetString.new(descr)),
		  SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.1.13",SNMP::OctetString.new(trace_url))
         ]

      SNMP::Manager.open(:Host => manager,:Version => :SNMPv1) do |snmp|
        snmp.trap_v1(
          "enterprises.10300.1.1.6",
          manager,
          :enterpriseSpecific, #Generic Trap Type
          trap_type, #Trap Type
          12345,
          var_binds
        )
    end
  end

  
  def InstrumentUtils.snmp_restore(manager,seq, alarm_type, utc_time)
    if !InstrumentUtils.validate_alarm_type(alarm_type)
      raise SNMP_Error.new("Alarm type [#{alarm_type}] not valid")
    end
    var_binds= [
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.2.1",SNMP::Integer.new(seq)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.2.3",SNMP::OctetString.new(alarm_type)),
          SNMP::VarBind.new("1.3.6.1.4.1.10300.1.1.2.2",SNMP::OctetString.new(utc_time))
         ]
      SNMP::Manager.open(:Host => manager,:Version => :SNMPv1) do |snmp|
        snmp.trap_v1(
          "enterprises.10300.1.1.6",
          manager,
          :enterpriseSpecific, #Generic Trap Type
          2, #Trap Type
          12345,
          var_binds
        )
    end
  end
end
end
#Avantron::InstrumentUtils.snmp_alarm("10.0.0.60",1,"Ingress", "Minor","12312312312z")
#Avantron::InstrumentUtils.snmp_restore("10.0.0.60",1,"Ingress", "Minor","12312312312z")
#Avantron::InstrumentUtils.reset('10.0.1.215')
