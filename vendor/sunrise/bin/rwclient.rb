#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../../../config/environment"

$:.push(File.expand_path(File.dirname(__FILE__))+"/../lib")
require 'yaml'
require 'date'
require 'rubygems'
require 'logger'
require 'timeout'
require 'zlib'
require 'digest/md5'
require 'digest/sha1'
require 'avantron'
require 'instrument_session'


#class Logger
#   class Formatter
#      Format='%Y-%m-%d %H:%M:%S'
#      def call(severity, time, progname, msg)
#         Format % [severity, format_datetime(time),progname,msg]
#      end
#   end
#end

def display_main_menu
   puts '################################'
   puts '# {N}- Network Stuff           #'
   puts '# {RF}- Read File              #'
   #   puts '# {GF}- Generate File          #'
   #   puts '# {D}- Run as Daemon           #'
   #   puts '# {TD}- Run as Trigger Daemon  #'
   puts '# {Q}- Quit                    #'
   puts '################################'
end
def display_network_menu
   puts '######################'
   puts '# {D}- Download File #'
   puts '# {GS}- Get Settings #'
   puts '# {DT}- Get Date Time #'
   puts '# {MS}- Mode Set     #'
   puts '# {U}- Upload File   #'
   puts '# {P}- Poll Analyzer #'
   puts '# {SL}- RPTP List    #'
   puts '# {SS}- Set Switch   #'
   puts '# {RD}- Run Diagnostic #'
   puts '# {RA}- Run Analog #'
   puts '# {RU}- Run AutoTest #'
   puts '# {RC}- Run Digital #'
   puts '# {RK}- Run Analog Ken #'
   puts '# {Q}- Return        #'
   puts '######################'
end
def network_functions(ip,logger, hmid)
   #instrument=InstrumentSession.new('70.89.89.17',3001,'10')
   puts "Logging into instrument #{ip}"
   instrument=InstrumentSession.new(ip,3001,'10',logger,hmid)
   #instrument=InstrumentSession.new('10.0.0.13',3001,'10')
   puts "Init Socket for #{ip}"
   instrument.initialize_socket()
   puts "Login Socket for #{ip} with HMID #{hmid}"
   instrument.login()
   display_network_menu()
   input=$stdin.gets().chomp().upcase()
   while ( input != 'Q' )
      begin
         if (input == 'SL')
            puts "Available Switches right? [Y]/N"
            available=$stdin.gets().chomp.upcase()
            result=nil
            if (available=='N')
               result=instrument.get_rptp_list(false)
            else
               result=instrument.get_rptp_list(true)
            end
            puts result.inspect()
         elsif (input == 'GS')
            gs=instrument.get_settings()
         elsif (input == 'DT')
            dt=instrument.get_date_time()
            puts dt.inspect()
         elsif (input == 'SS')
            puts "What switch would you like"
            switch=$stdin.gets().chomp().upcase().to_i()
            instrument.set_switch(switch)
         elsif (input == 'MS')
            mode_list=[ 'Spectrum Analyzer' ,'System Sweep','Bidirectional Alignment System','Digital Channel Power',
               'Frequency Counter', 'TV Channel', 'Multi Carrier','Auto Test','HUM', 'C/N, CSO, CTB',
               'Frequency Response', 'Depth of Modulation', '','Monitoring','Time Domain Analyzer', 'QAM Analyzer',
            'Monitoring Reserved', '','QAM Monitoring', 'CATV monitoring']
            puts "AVAILABLE MODES"
            puts "---------------"
            mode_list.each_index {|idx| puts "#{idx} - #{mode_list[idx]}"}
            puts "What Mode would you like"
            mode=$stdin.gets().chomp().upcase().to_i()
            instrument.set_mode(mode)
         elsif (input == 'P')
            puts "Enter the poll count"
            cnt=$stdin.gets().chomp
            instrument.monitor_client(cnt.to_i||10)
         elsif (input == 'RD')
            instrument.set_mode(15)
            puts "Enter Frequency [765.0]"
            freq=$stdin.gets().chomp.to_f*1000000 || 765000000
            instrument.set_settings({"central_freq"=>freq.to_i})
            response=instrument.diagnostic()
            puts response.inspect()
         elsif (input == 'RA')
            instrument.set_mode(0)
            puts "Enter Frequency [55.25]"
            freq=$stdin.gets().chomp.to_f*1000000.0 || 55250000
            puts "Setting Frequency to #{freq}"
            instrument.set_settings({"central_freq"=>freq.to_i})
            instrument.set_mode(4)
            response=instrument.analog_trigger()
            puts "TRIGGER:"
            puts response.inspect()
            #instrument.set_mode(11)
            #response=instrument.get_modulation()
            #puts "Modulation"
            #puts response.inspect()
         elsif (input == 'RU')
            instrument.set_mode(7)
            response=instrument.analog_trigger()
            puts "TRIGGER:"
            puts response.inspect()
            #instrument.set_mode(11)
            #response=instrument.get_modulation()
            #puts "Modulation"
            #puts response.inspect()
         elsif (input == 'RC')
            instrument.set_mode(15)
            puts "Enter Frequency [55.25]"
            freq=$stdin.gets().chomp.to_f*1000000.0 || 55250000
            puts "Enter Modulation {0=> 'QAM64',1=>'QAM256'}"
            mod_flag=$stdin.gets().chomp.to_i || 0
            modulation=( mod_flag == 1 ? 5 : 3)
            symb_rate=0
            if (mod_flag == 5)
               symb_rate=5360537
            else
               symb_rate=5056941
            end
            puts "Setting Frequency to #{freq}"
            puts "Select Annex { 0=>none, 1=>A, 2=>B, 3=>C }"
            annex=$stdin.gets().chomp.to_i || 0
            settings=instrument.set_settings({"central_freq"=>freq.to_i, 
               "modulation_type" =>modulation, "standard_type"=>annex, "ideal_symbol_rates"=>symb_rate})
            puts "Settings = #{settings}"
            puts "Frequency set to #{freq}"
            response=instrument.digital_trigger(1)
            puts "TRIGGER:"
            puts response.inspect()
            #instrument.set_mode(11)
            #response=instrument.get_modulation()
            #puts "Modulation"
            #puts response.inspect()
         elsif (input == 'RK')
            puts "Enter Frequency [55.25]"
            freq=$stdin.gets().chomp.to_f*1000000.0 || 55250000
            puts "Setting Frequency to #{freq}"
            instrument.set_mode(5)
            instrument.set_settings({"central_freq_1"=>freq.to_i})
            response=instrument.analog_trigger()
            puts "RESPONSE IS:"
            puts response.inspect()
         elsif (input == 'U')
            def_fname="/tmp/run"
            puts "Enter the file to upload [#{def_fname}]"
            fname=$stdin.gets().chomp
            if fname==''
               fname=def_fname
            end
            instrument.upload_file(fname,fname)
         elsif (input == 'D')
            def_fname="/usr/local/bin/atsoft/monitor.swt"
            puts "Enter the filename[/usr/local/bin/atsoft/monitor.swt"
            fname=$stdin.gets().chomp
            if fname==''
               fname=def_fname
            end
            instrument.download_file(fname)
         else
            puts "Do not recognize command #{input}"
         end
         display_network_menu()
         input=$stdin.gets().chomp().upcase()
      rescue Exception => e
         puts e.message
         puts e.backtrace
         puts "Logging out of instrument"
         raise("Failed to Logoff to instrument") if (instrument.msg_with_ack('04','001',{'resv1'=>0},1)!=1)
         instrument.close_session()
      end
   end
   puts "Logging out of instrument"
   instrument.logout()
   instrument.close_session()
end

def init_ar(params)
  ActiveRecord::Base.establish_connection(:adapter=>params['adapter'],:host=>params['host'],
     :username => params['username'], :database => params['database'])
end

def daemon(analyzer_id, logger)
   anl=Analyzer.find(analyzer_id)
   ip=anl[:ip]
   instrument=InstrumentSession.new(ip,3001,'10',logger)
   instrument.initialize_socket()
   instrument.login()
   puts "Build Port Details"
   port_list=[]
   port_setting_hash={}
   instrument.set_mode(13)
   anl.switches.find(:all).each { |switch|
      switch.switch_ports.find(:all).each { |switch_port|
         calc_port=switch_port.get_calculated_port
         #puts "Calc Port: #{calc_port}"
         #puts switch_port.inspect()
         port_list.push(calc_port)
         port_settings=instrument.get_source_settings(calc_port).msg_obj()
         port_setting_hash[calc_port.to_s]=port_settings
         #attenuator_values[calc_port.to_s]=port_settings['attenuator_value']
         #switch_port.update_attribute(:attenuator,port_settings['attenuator_value'].to_f)
         #switch_port.update_attribute(:center_frequency,port_settings['cen_freq'].to_f)
         #switch_port.update_attribute(:span,port_settings['span'].to_f)
      }
   }
   puts port_list.inspect()
   instrument.flush_alarms()
   instrument.flush_stats()
   instrument.start_monitoring()
   #instrument.select_request_list(port_list)
   instrument.throttle(50,10)

   #GET INITIAL STATUS
   instrument.curr_state=InstrumentSession::Ingress
   time_marker = Time.now()
   iteration=0
   initdata=[]
   datalog=[]
   maxdata=[]
   mindata=[]
   puts "Init Ports"
   port_list.each { |port|
      initdata[port]=[]
      datalog[port]=[]
      maxdata[port]=[]
      mindata[port]=[]
      500.times { |idx| 
         initdata[port][idx]=0
         datalog[port][idx]=0
         maxdata[port][idx]=0
         mindata[port][idx]=1024
      }
   }
   puts "Starting Monitor"
   instrument.set_working_mode(0)
   puts "Get Source Settings"
   response=instrument.get_source_settings(0)
   puts response.inspect()
   #GET INITIAL STATUS
   time_marker=Time.now()
   instrument.command_io=$stdin
   instrument.select_request(0)
   while ( instrument.curr_state==InstrumentSession::Ingress)
      msg_obj=instrument.poll_status_monitoring()
      puts "ALARM COUNT: #{msg_obj['alarm_count']} STAT COUNT: #{msg_obj['statistic_count']} INTEGRAL COUNT: #{msg_obj['integral_count']} MONITORING STATUS: #{msg_obj['monitoring_status']}"
      if msg_obj['monitoring_status'] == 69
         puts "ERROR: #{msg_obj['error_nbr']}"
         instrument.clear_monitoring_error()
      end
      alarm_count=msg_obj['alarm_count'].to_i
      stat_count=msg_obj['statistic_count'].to_i
      while ( stat_count > 0 )
         puts "Getting Stats"
         response=instrument.next_stat()
         #TODO do something with the msg_obj
         msg_obj=response.msg_obj()
         stat_count=msg_obj{numb_of_xmit_stastics}.to_i
      end
      while ( alarm_count > 0 )
         puts "Getting Alarms #{alarm_count}"
         alarm_response=instrument.next_alarm()
         #TODO do something with the msg_obj
         msg_obj=alarm_response.msg_obj()
         rescue_count=0
         begin
            schedule=Schedule.find(msg_obj['sn_schedule'])
            rescue_count += 1
         rescue Mysql::Error => e
            puts "Mysql Rescue Count #{rescue_count}"
            if (rescue_count < 3)
               Schedule.connection.reconnect!()
               retry
            end
         rescue Exception => e
            puts "Rescue Count #{rescue_count}"
            puts e.inspect()
            if (rescue_count < 3)
               Schedule.connection.reconnect!()
               retry
            end
         end
         raise "Cannot find schedule #{msg_obj['sn_schedule']} in database" if (schedule.nil?)
         step_nbr=msg_obj['step_nbr']
         if (schedule.scheduled_sources[step_nbr].nil?)
            puts schedule.scheduled_sources.inspect()
            raise "Nothing scheduled for step: #{step_nbr}"
         end
         port_id=schedule.scheduled_sources[step_nbr].switch_port_id
         port_nbr=schedule.scheduled_sources[step_nbr].switch_port.get_calculated_port()
         raise "Cannot find Port  in database" if (port_id.nil?)
         trace=nil
         alarm=Alarm.new(
            :switch_port_id => port_id,
            :sched_sn_nbr => msg_obj['sn_schedule'],
            :step_nbr => msg_obj['step_nbr'],
            :monitoring_mode => msg_obj['monitoring_mode'],
            :calibration_status => msg_obj['calibration_status'],
            :event_time => DateTime.civil(
               msg_obj['event_year'],
               msg_obj['event_month'],
               msg_obj['event_day'],
               msg_obj['event_hour'],
               msg_obj['event_minute'],
               msg_obj['event_second']),
            :event_time_hundreths => msg_obj['sec_hundreths'],
            :alarm_level => msg_obj['alarm_level'],
            :alarm_deviation => msg_obj['alarm_deviation'],
            :external_temp => msg_obj['event_extern_temp'],
            :center_frequency => port_setting_hash[port_nbr.to_s]['cen_freq'] ,
            :span => port_setting_hash[port_nbr.to_s]['span'] 
         )
         if msg_obj['subcommand'] == 47
            packed_image_arr=alarm_response.msg_obj()['trace'].unpack('C*')
            raw_image=Avantron.parse_image(packed_image_arr)
            db_constant=70.0/1024.0
            processed_image=raw_image.collect {|val| val=(val-1023) * db_constant 
               + port_setting_hash[port_nbr.to_s]['attenuator_value'] }
            alarm.image=processed_image
         else
            puts "Hi guys we got message type #{alarm_response.msg_type}"
         end

         alarm.save()
         puts("Response-> Msg Type:#{alarm_response.msg_type} Step Nbr:#{msg_obj['step_nbr']} ")
         #puts ("RESPONSE  #{alarm_response.msg_type.to_s}#{alarm_response.msg_obj()['subcommand']}")
         alarm_count=msg_obj["numb_of_xmit_alarms"].to_i
         #puts "Now at #{alarm_count}"
      end
      #instrument.trigger()
      raise "Failed to Get SERIAL" if (instrument.msg_with_ack('90','002',{'subcommand'=>15, 'resv1'=>255},0)!=1)
      response_packet=instrument.read_response(10)
      response=AvantronRec.parsePacket(response_packet,true, logger)
      raise "Did not get a STATUS Response #{response.inspect}" if ((response.msg_type.to_i != 90) && (response.msg_obj()['subcommand'].to_i()!=15))
      sleep 3
   end
   raise "Failed to Stop Monitoring" if (instrument.msg_with_ack('90','002',{'subcommand'=>2})!=1) #Stop Monitoring
   raise ("Failed to Change Mode") if (instrument.msg_with_ack('94','002',{'desiredmode'=>13},2)!= 1)
   instrument.logout()
   instrument.close_session()
   
end
#Monitoring By Trigger
def trigger_daemon(ip, logger)
   poll_period=5
   switch_id=1
   puts "Logging into instrument #{ip}"
   instrument=InstrumentSession.new(ip,3001,'10',logger)
   #instrument=InstrumentSession.new('10.0.0.13',3001,'10')
   instrument.initialize_socket()
   instrument.login()
   instrument.set_switch(switch_id)
   instrument.set_mode(0)
   settings=instrument.get_settings()
   puts "Got Settings"
   attenuator=settings['attenuator']
   span=settings['span']
   center_freq=settings['central_freq']
   puts settings.inspect()
   instrument.curr_state=InstrumentSession::Ingress
   response=instrument.get_source_settings(0)
   puts response.inspect()
   time_marker = Time.now()
   iteration=0
   initdata=[]
   datalog=[]
   maxdata=[]
   mindata=[]
   500.times { |idx| 
      initdata[idx]=0
   datalog[idx]=0
   maxdata[idx]=-10000
   mindata[idx]=1024
   }
   begin
      while(instrument.curr_state == InstrumentSession::Ingress)
         raise("Failed to Trigger") if (instrument.msg_with_ack('98','001',{'trace_count_to_perform'=>1,
           'acquisition_buffer_reset'=>0 },1)!=1)
         response_packet=instrument.read_response(10)
         response=AvantronRec.parsePacket(response_packet,true, logger)
         packed_image_arr=response.msg_obj()['aligned_image'].unpack('C*')
         #$LOG.debug(packed_image_arr.inspect)
         raw_image=Avantron.parse_image(packed_image_arr)
         db_constant=70.0/1024.0
         result=raw_image.collect {|val| val=(val-1023) * db_constant + attenuator}

         result.each_index { |idx|
            datalog[idx]=(datalog[idx]*1.0*iteration+result[idx])/(iteration+1.0)
            maxdata[idx]=(result[idx]>maxdata[idx]) ? result[idx] : maxdata[idx]
            mindata[idx]=(result[idx]<mindata[idx]) ? result[idx] : mindata[idx]
         }
         iteration=iteration + 1
         if (Time.now()-time_marker > 1)#Eventually this will be 60
            datalog_obj=Datalog.new()
            datalog_obj.span=span
            datalog_obj.center_frequency=center_freq
            datalog_obj.image=datalog
            datalog_obj.max_image=maxdata
            datalog_obj.min_image=mindata
            datalog_obj.raw_image=raw_image
            datalog_obj.sample_count=iteration
            datalog_obj.ts=DateTime.now()
            datalog_obj.rptp=0
            datalog_obj.save()
            #Store
            time_marker=Time.now()
            iteration=0
            datalog=initdata
            maxdata=initdata
            mindata=initdata.collect {|x| 1024}
         else
            
         end
         #if (Time.now()-time_marker < poll_period)
         #   puts "Poll Now @ #{iteration}"
         #   instrument.monitor_client(1)
         #   instrument.set_switch(switch_id)
         #   instrument.set_mode(0)
         #   time_marker=Time.now()
         #end

      end

   rescue Exception => e
      puts e.message
      puts e.backtrace
      puts "Logging out of instrument"
      instrument.logout()
      instrument.close_session()
   end
   raise("Failed to Logoff to instrument") if (instrument.msg_with_ack('04','001',{'resv1'=>0},1)!=1)
   instrument.close_session()

end
puts ARGV.inspect()
if ARGV.length == 2
   ip=ARGV[0]
   hmid=ARGV[1]
else
  raise "USAGE rwclient.rb ip hmid"
end
puts "IP=#{ip}"
logger=Logger.new('rwclient.log')
logger.debug("STARTING RW CLIENT")
#dbparams=YAML.load_file('/usr/local/apache2/htdocs/realworx/config/database.yml')
#init_ar(dbparams['development'])
display_main_menu()
input=$stdin.gets().chomp().upcase()
while ( input != 'Q' )
   begin
      if (input == 'RF') #Running File stuff
         def_fname="/tmp/monitor.sch"
         puts "Enter the file to Read [#{def_fname}]"
         fname=$stdin.gets().chomp
         if fname==''
            fname=def_fname
         end
         af=MonitorFiles::MonitoringFile.read(fname)
         puts af.inspect()
         af.write("#{fname}.out")
      elsif (input == 'GF')
         puts ("####################")
         puts ("# A Switch File    #")
         puts ("# B Schedule File  #")
         puts ("# C Signal File  #")
         puts ("# R Return         #")
         puts ("####################")
         input=$stdin.gets().chomp().upcase()
         if (input == 'A')
            anl_list=[]
            Analyzer.find(:all).each {|anl| anl_list.push(anl)}
            puts("####################")
            anl_list.each_index {|anl_idx| puts("# #{anl_idx}. #{anl_list[anl_idx][:name]}")}
            puts("####################")
            puts("Select an analyzer associated with the switch network")
            input=$stdin.gets().chomp().upcase().to_i
            puts("You've selected [#{anl_list[input][:name]}/#{anl_list[input][:ip]}]")
            obj=MonitorFiles::SwitchesFO::build(anl_list[input].id)
            af=MonitorFiles::MonitoringFile::new()
            af.obj_list=([obj])
            af.write('/tmp/monitorx.swt')
            puts af.inspect()
         end
         if (input == 'B')
            anl_list=[]
            Analyzer.find(:all).each {|anl| anl_list.push(anl)}
            puts("####################")
            anl_list.each_index {|anl_idx| puts("# #{anl_idx}. #{anl_list[anl_idx][:name]}")}
            puts("####################")
            puts("Select an analyzer associated with the switch network")
            input=$stdin.gets().chomp().upcase().to_i
            puts("You've selected [#{anl_list[input][:name]}/#{anl_list[input][:ip]}]")
            obj=ScheduleFO::build(anl_list[input].id)
            af=MonitorFiles::MonitoringFile::new()
            af.obj_list=([obj])
            af.write('/tmp/monitorx.sch')
            puts af.inspect()
         end
         if (input == 'C')
            anl_list=[]
            Analyzer.find(:all).each {|anl| anl_list.push(anl)}
            puts("####################")
            anl_list.each_index {|anl_idx| puts("# #{anl_idx}. #{anl_list[anl_idx][:name]}")}
            puts("####################")
            puts("Select an analyzer associated with the switch network")
            input=$stdin.gets().chomp().upcase().to_i
            puts("You've selected [#{anl_list[input][:name]}/#{anl_list[input][:ip]}]")
            obj_list=SignalsFO::build(anl_list[input].id)
            af=MonitorFiles::MonitoringFile::new()
            af.obj_list=obj_list
            af.write('/tmp/monitorx.sig')
            puts af.inspect()
         end
      elsif (input == 'N')   #Running Network stuff
         network_functions(ip,logger, hmid)
      elsif (input == 'D')   #Running As Daemon
         anl_list=[]
         Analyzer.find(:all).each {|anl| anl_list.push(anl)}
         puts("####################")
         anl_list.each_index {|anl_idx| puts("# #{anl_idx}. #{anl_list[anl_idx][:name]}")}
         puts("####################")
         puts("Select an analyzer associated with the switch network")
         input=$stdin.gets().chomp().upcase().to_i
         daemon(anl_list[input][:id], logger)
      elsif (input == 'TD')   #Running As Trigger Daemon
         trigger_daemon('10.0.0.125',logger)
      end
      rescue Exception => e
         puts "#{Time.now()} #{e.message}"
         puts e.backtrace
   end
   display_main_menu()
   input=$stdin.gets().chomp().upcase()
end
