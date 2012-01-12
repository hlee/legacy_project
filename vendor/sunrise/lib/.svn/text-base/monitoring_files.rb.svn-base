module MonitorFiles
   #####################################################################################
   ###
   ###
   ###
   ################
   class MonitoringFile
      attr_accessor :obj_list
      def initialize()
         @obj_list=[]
      end
      def inspect()
         result_str=''
         @obj_list.each { |x|
            result_str << x.inspect()<< "\n"
         }
         return result_str
      end
      def write(fname)
         prev_schema = nil
         schema_count = 0
         open(fname,'w') { |f|
            obj_len=@obj_list.length
            if (obj_len < 0xffff)
               f.write([obj_len].pack('S'))
            else
               f.write([0xffff,obj_len].pack('SL')) #If obj count > 65535 then signal with the 0xffff and write length as long
            end
            @obj_list.each {|obj| #Loop over list of objects
               if (prev_schema.nil? ) || (prev_schema !=obj.schema)
                  #Writing header for new schema
                  schema_count=schema_count+1
                  f.write([0xffff].pack('S')) 
                  f.write([obj.schema, obj.obj_name.length, obj.obj_name].pack("SSa*"))
                  prev_schema=obj.schema
               else
                  rec_id=0x8000+schema_count
                  f.write([rec_id].pack('S')) 
               end
               obj.write(f)
            }
         }
      end
      def MonitoringFile.read(fname)
         avantron_file=MonitoringFile.new()
         recs=[]
         #puts "Opening [#{fname}]"
         open(fname) {|f|
            #read Header
            obj_count=f.read(2).unpack('S')[0]
            if (obj_count == 0xffff)
               obj_count=f.read(4).unpack('L')[0]
            end
            obj_name=nil
            schema=nil
            obj_list=[]
            obj_type_count=0
            obj_count.times { |obj_idx|
               hdr_id=f.read(2).unpack('S')[0]
               #puts "OBJ COUNT #{obj_count}, #{hdr_id} @ #{f.pos}"
               if (hdr_id.to_i == 65535)
                  #Start of a new object type
                  obj_type_count=obj_type_count+1
                  schema=f.read(2).unpack('S')[0]
                  obj_name_len=f.read(2).unpack('S')[0]
                  obj_name=f.read(obj_name_len)
                  rec={}
               elsif (hdr_id.to_i != (32768+obj_type_count))
                  raise("for hdr_id expecting #{32768+obj_type_count} but we got #{hdr_id}")
               end
               #puts "SCHEMA is #{schema}, #{obj_name}"
               file_obj=FileObj.read(f, obj_name, schema)
               obj_list.push(file_obj)
            }
            avantron_file.obj_list=obj_list
            if (f.read(1).nil?)
               #Put a logging message here
            else
               raise("We have more content at #{f.pos}")
            end
         }
         return avantron_file
      end
   end
   #####################################################################################
   ###
   ###
   ###
   ################
   class FileObj
      TRACE_REF_SCHEMA=2
      SCHEDULE_SCHEMA=4
      SWITCH_SCHEMA=3
      SIGNAL_SCHEMA=2
      attr_reader :obj_name, :schema
      def FileObj::read(f,obj_name, schema)
         if (schema == SCHEDULE_SCHEMA)
            file_obj=ScheduleFO.specRead(f, obj_name)
         elsif (schema == SWITCH_SCHEMA)
            file_obj=SwitchesFO.specRead(f, obj_name)
         elsif (obj_name == 'CSignalSource')
            file_obj=SignalsFO.specRead(f, obj_name)
         elsif (obj_name == 'CTraceReference')
            file_obj=TraceReferenceFO.specRead(f, obj_name)
         else
            raise("schema '#{schema}' is not understood")
         end
         return file_obj
      end
   end
   #####################################################################################
   ###
   ###
   ###
   ################
   class ScheduleFO < FileObj
      attr_reader :schedule_index,
         :update_value,
         :serial_number,
         :comment, 
         :acquisition_count,
         :attenuator_value,
         :sample_time,
         :alarm_list, #KEYS=[alarm_name, alarm_deviation, min_time (between alarms), transfer_trace(flag)]
         :stat_trace_flag,
         :integral_trace_flag,
         :trace_polling_period,
         :signal_source_list #KEYS=[src_nbr, stat_trace_flag, integral_flag]
      attr_writer :schedule_index,
         :update_value,
         :serial_number,
         :comment, 
         :acquisition_count,
         :attenuator_value,
         :sample_time,
         :alarm_list,
         :stat_trace_flag,
         :integral_trace_flag,
         :trace_polling_period,
         :signal_source_list
      def initialize( obj_name)
         @schema=SCHEDULE_SCHEMA
         @obj_name=obj_name
         @alarm_list=[]
         @signal_source_list=[]
      end
      def inspect()
         result_str=''
         result_str  << "<" << @obj_name << "\n"
         result_str << " schedule_index:" << @schedule_index << "\n"
         result_str << " update_value:" << @update_value << "\n"
         result_str << " serial_number" << @serial_number.to_s << "\n"
         result_str << " comment:" << @comment.to_s << "\n"
         result_str << " acquisition_count:" << @acquisition_count.to_s << "\n"
         result_str << " attenuator :" << @attenuator_value.to_s << "\n"
         result_str << " sample_time:" << @sample_time.to_s << "\n"
         @alarm_list.each { |alm| result_str << "  " << alm.inspect() << "\n"}
         result_str << " stat_trace_flag" << @stat_trace_flag.to_s << "\n"
         result_str << " integral_trace_flag:" << @integral_trace_flag.to_s << "\n"
         result_str << " trace_polling_period:" << @trace_polling_period.to_s << "\n"
         @signal_source_list.each { |src| result_str << "  " << src.inspect() << "\n"}
         return result_str
      end
      def write(f)
         data=[@schedule_index,@update_value,@serial_number,@comment,@acquisition_count,
            @attenuator_value, @sample_time, @alarm_list.length]
         f.write(data.pack('LLLa41CCSC'))
         puts "Writing Schedule"
         puts data.inspect()
         @alarm_list.each { |alarm|
            data=[alarm[:alarm_name],alarm[:alarm_deviation],alarm[:min_time],alarm[:transfer_trace]]
            f.write(data.pack('a16SCC'))
         }
         data=[@stat_trace_flag, @integral_trace_flag, @trace_polling_period, @signal_source_list.length]
         f.write(data.pack('CCSS'))
         @signal_source_list.each {|src|
            data=[src[:src_nbr],src[:stat_trace_flag],src[:integral_flag]]
            f.write(data.pack('SCC'))
         }
      end
      def ScheduleFO::specRead(f,obj_name)
         schedule=ScheduleFO.new(obj_name)
         data=f.read(58).unpack('LLLA41CCSC')
         schedule.schedule_index=data[0]
         schedule.update_value=data[1]
         schedule.serial_number=data[2]
         schedule.comment=data[3]
         schedule.acquisition_count=data[4]
         schedule.attenuator_value=data[5]
         schedule.sample_time=data[6]
         alarm_threshold_count=data[7]
         alarm_threshold_count.times {
            data_rec=f.read(20).unpack('A16SCC')
            schedule.alarm_list.push({:alarm_name=>data_rec[0],:alarm_deviation=>data_rec[1],
               :min_time=>data_rec[2],:transfer_trace=>data_rec[3]})
         }
         data_rec=f.read(6).unpack('CCSS')
         schedule.stat_trace_flag=data_rec[0]
         schedule.integral_trace_flag=data_rec[1]
         schedule.trace_polling_period=data_rec[2]
         signal_src_cnt=data_rec[3]
         signal_src_cnt.times {
            data_rec=f.read(4).unpack('SCC')
            schedule.signal_source_list.push(
               {:src_nbr=>data_rec[0],:stat_trace_flag=>data_rec[1],:integral_flag=>data_rec[2]})
         }
         return [schedule]
      end
      def ScheduleFO::build(analyzer_id, obj_name='CSchedule')
         analyzer_obj=Analyzer.find(analyzer_id)
         schedule_obj=analyzer_obj.schedule
         schedule=ScheduleFO.new( obj_name)
         schedule.comment=schedule_obj.comment
         schedule.acquisition_count=schedule_obj.acquisition_count
         schedule.attenuator_value=analyzer_obj.attenuator
         schedule.sample_time=schedule_obj.sample_time
         #These are nolonger used anymore
         #schedule.stat_trace_flag=schedule_obj.stat_trace_flag ? 1 : 0
         #schedule.integral_trace_flag=schedule_obj.integral_trace_flag ? 1 : 0
         schedule.stat_trace_flag=2
         schedule.integral_trace_flag= 0
         schedule.trace_polling_period=schedule_obj.trace_polling_period
         src_list=[]
         schedule_obj.scheduled_sources.each { |sched_src|
            port={}
            if sched_src.switch_port.nil?
               return nil
            end
            if (sched_src.switch_port.is_return_path?)
              port[:src_nbr]=sched_src.switch_port.get_calculated_port() -1 #Subtracting 1 for this file, I for scenario when I had one switch
              port[:integral_flag]=sched_src.stat_trace_flag==1 ? 1 : 0
              port[:stat_trace_flag]=sched_src.integral_trace_flag==1 ? 1 : 0
              src_list.push(port)
            end
         }
         schedule.signal_source_list=src_list
         #Hard Coded Items
         schedule.alarm_list=[
            {:alarm_name=>"Minor", :alarm_deviation=>2, :min_time=>0, :transfer_trace=>1}, 
            {:alarm_name=>"Warning", :alarm_deviation=>2, :min_time=>0, :transfer_trace=>1}, 
            {:alarm_name=>"Major", :alarm_deviation=>2, :min_time=>0, :transfer_trace=>1}, 
            {:alarm_name=>"Critical", :alarm_deviation=>2, :min_time=>0, :transfer_trace=>1}, 
            {:alarm_name=>"Link Loss", :alarm_deviation=>1000, :min_time=>0, :transfer_trace=>1}]
         schedule.schedule_index=schedule_obj.id
         schedule.update_value=26
         schedule.serial_number=schedule_obj.id
         return [schedule]
      end
   end
   #####################################################################################
   ###
   ### Signal File Object
   ###
   ################
   class SignalsFO < FileObj
      attr_reader :comment,:rptp_idx, :stack,:stat_flag,:int_flag
      attr_writer :comment,:rptp_idx, :stack,:stat_flag,:int_flag
      def initialize( obj_name)
         @schema=SIGNAL_SCHEMA
         @obj_name=obj_name
      end
      def write(f)
         data=[@comment, @rptp_idx, @stack,@stat_flag,@int_flag]
         f.write(data.pack('a16SCCC'))
      end
      def SignalsFO::specRead(f,obj_name)
         signal=SignalsFO.new(obj_name)
         rec_data=f.read(21).unpack('A16SCCC')
         signal.comment=rec_data[0]
         signal.rptp_idx=rec_data[1]
         signal.stack=rec_data[2]
         signal.stat_flag=rec_data[3]
         signal.int_flag=rec_data[4]
         return signal
      end
      def SignalsFO::build(analyzer_id, obj_name='CSignalSource')
         signal_list=[]
         analyzer_obj=Analyzer.find(analyzer_id)
         switches=analyzer_obj.switches
         switches.each { |switch_obj|
            if (!switch_obj.master_switch_flag)

               switch_obj.switch_ports.each { |switch_port_obj|
                  signal=SignalsFO.new( obj_name)
                  calculated_port=switch_port_obj.get_calculated_port()
                  signal.rptp_idx=calculated_port
                  signal.stack=0
                  #signal.stat_flag=switch_port_obj.stat_trace_flag ? 1 : 0
                  signal.stat_flag=1
                  signal.int_flag=1
                  signal.comment=switch_port_obj.name
                  signal_list.push(signal)
               }

            end
         }
         return signal_list
      end
   end

   #####################################################################################
   ###
   ###Trace Reference Object
   ###
   ####################
   class TraceReferenceFO < FileObj
      attr_accessor :obj_name, :schema, 
         #AT2000STATUS Starts here (at2000status.h)
         :name, :comment, 
         :tm,:temp_external, :current_mode, :attenuation, :if_offset,
         :ref_offset, :center_freq,
         #We are going to assume Spectrum Analyzer here (at2000status.h)
         :at2000status, 
         #:at2000status_str,
         :trace, 
         :user, :swcomment, :company_name, :software_ver, :cal_date, :model_nbr, :reserved,  #74 bytes
          :trace_comment, :thresh_list # Thresh is a 3byte record

#pulled from the presets.h file. rever to SAStatus structure

      StatusLabelsSA=[:video_channel,:audio_channel, :span,:zero_span_mode,#1
         :sweep_time, :auto_sweep_time, :horz_time, :auto_horz_time,#2,4
         :resol_bwd, :auto_resol_bwd, :video_bwd, :auto_video_bwd, #3,4
         :vertical_scale, :mk_v1,:mk_v2,:mk_h1,:mk_h2,#4,5
         :mk_v1_b, :mk_v2_b, :mk_h1_b, :mk_h2_b, :trace_mode, :volume,#5,6
         :center_freq_amp, :mk_v1_amp,:mk_v2_amp,:mk_fm_pos,#6,4
         :noise_mark, :trigger_video_line, :max_center_freq,#7,3
         :resv, :v1_trace_nbr, :v2_trace_nbr,:is_peak_search,#8,4
         :peak_search_detect, :peak_search_nbr, #9,2
         :v2_tracking_mode, :v2_tracking_delta, #10,2
         :tilt_mk_trace, :tilt_mk_low_freq, :tilt_mk_high_freq,#11,3
         :tilt_mk_low_freq_lvl, :tilt_mk_tilt,#12,2
         :leftovers];#13,1
                     #14   #14    #20    #22     #12
      StatusSigSA= 'ssds'+'ssds'+'dsds'+'sddss'+'sssssS'+
         'ssss'+ 'ssc' + 'a20SSs'+'sS'+'sl'+'sLL'+'ss'+"a*"
         #8        5        26
        Signature='x2a9a41a18sssssda200a625a31a41a31a12a13a11x74a41c'

        #def inspect()
        # result=''
        # result << "video_channel:"<<@video_channel
        # result << "audio_channel:"<<@audio_channel
        # result << "span:"<<@span
        # result << "zero_span_mode:"<<@zero_span_mode
        # result << "sweep_time:"<<@sweep_time
        # result << "auto_sweep_time:"<<@auto_sweep_time
        # result << "horz_time:"<<@horz_time
        # result << "auto_horz_time:"<<@auto_horz_time
        # result << "resol_bwd:"<<@resol_bwd
        # result << "auto_resol_bwd:"<<@auto_resol_bwd
        # result << "video_bwd:"<<@video_bwd
        # result << "auto_video_bwd:"<<@auto_video_bwd
        #end
      ###############
      # Constructor
      ########
      def initialize(obj_name)
         @schema=TRACE_REF_SCHEMA
         @obj_name=obj_name
         @thresh_list=[]
         @at2000status={
            :time=>0, #18 bytes long
            :tExt=>nil, #ExternalTemp short -275 thru 225
            :current_mode=>nil, 
            :attenuation=>nil, 
            :ifoffset=>nil, 
            :buffer=>nil# the 200 byte union.
         }
      end
      def write(f)
         #buffer74=''
         #74.times {|i| buffer74 << "\000"}
         #raise 'buffer74 failed' if (buffer74.length != 74)
         status_data=StatusLabelsSA.collect { |key| 
            at2000status[key] }
         at2000status_str=status_data.pack(StatusSigSA)
         data_set=[
            @name, @comment, @tm,@temp_external,@current_mode,
            @attenuation,@if_offset,@ref_offset, @center_freq,
            at2000status_str,
            #@trace.pack("S*"),
            Common.pack_image(@trace), 
            @user,@swcomment, @company_name, @software_ver,@cal_date,@model_nbr,
            @trace_comment,
            #TraceReference
            @thresh_list.length]

            puts data_set.inspect()
            puts Signature.inspect()
            puts ref_offset.inspect()
         f.write( data_set.pack(Signature))
            @thresh_list.each { |thresh|
               f.write([thresh[:offset],thresh[:type]].pack('sc'))
            }
      end
      def TraceReferenceFO::build(analyzer_id, obj_name='CTraceReference')
         reference_list=[]
         anl=Analyzer.find(analyzer_id)
         anl.switches.each {|swt|
            swt.switch_ports.each { |swp|
               obj=TraceReferenceFO.new(obj_name)
               obj.schema=2
               obj.tm=''
               obj.company_name=''
               obj.comment=''
               obj.model_nbr=''
               obj.current_mode=0
               obj.swcomment=''
               #obj.ref_offset=anl.ref_offset
               obj.ref_offset=0
               obj.trace_comment=''
               obj.software_ver=''
               span=anl.stop_freq - anl.start_freq
               #span=20000000
               obj.center_freq=anl.start_freq+span/2.0
               obj.at2000status={
                  :tilt_mk_low_freq_lvl=>0, :auto_horz_time=>0,
                  :v2_tracking_mode=>0, :mk_v2_amp=>0, :mk_v2=>0,
                  :resol_bwd=>anl.resol_bwd, :video_channel=>0,
                  :tilt_mk_tilt=>0, :vl_trace_nbr=>0, :mk_h2_b=>0,
                  :auto_resol_bwd=>0, :v2_tracking_delta=>0, :mk_fm_pos=>0,
                  :mk_h1=>0, :mk_h1_b=>0,:trace_mode=>0, :resv=>'',
                  :span=> span,:v1_trace_nbr=>0,
                  :audio_channel=>0,
                  :leftovers=> '', :v2_trace_nbr=>0 , :race_mode=>0,
                  :video_bwd=>anl.video_bwd, :tilt_mk_trace=>0, :noise_mark=>0,
                  :mk_h2=>0, :zero_span_mode=>0, :ifoffset=>nil,
                  :is_peak_search=>0, :volume=>0, :auto_video_bwd=>0,
                  :sweep_time=>anl.sweep_time, :tilt_mk_low_freq=>0, 
                  :trigger_video_line=>0,
                  :mk_v1_b=>0, :auto_sweep_time=>0, :current_mode=>nil,
                  :peak_search_detect=>0, :center_freq_amp=>0, 
                  :vertical_scale=>10,
                  :tilt_mk_high_freq=>0, :max_center_freq=>0, :mk_v2_b=>0,
                  :horz_time=>0.0, :attenuation=>nil, :time=>0,
                  :peak_search_nbr=>0, :mk_v1_amp=>0, :mk_v1=>0.0
               }
               StatusLabelsSA.each { |key| 
                  if (!obj.at2000status.key?(key) || obj.at2000status[key].nil?)
                     raise "What is wrong with #{key}"
                   end
               }
               obj.cal_date="" 
               obj.temp_external=0 
               obj.user="" 
               obj.if_offset=0
               selected_profile=swp.profile
               if (selected_profile.nil?)
                  selected_profile=anl.profile
                  #TODO If selected Profile is still nil then set the selected_profile to the default profile.
               end
               if selected_profile.nil?
                  raise SunriseError.new("No Profile Selected")
               end
               obj.name=selected_profile.name #Set from profile id for each port
               obj.comment=selected_profile.comment 
               #Set for each signal source
               obj.thresh_list=[ 
                  {:offset=>selected_profile.minor_offset*10, :type=>2},
                  {:offset=>100, :type=>0},
                  {:offset=>selected_profile.major_offset*10, :type=>2},
                  {:offset=>200, :type=>0},
                  {:offset=>selected_profile.loss_offset*10, 
                     :type=>selected_profile.link_loss ? 1 : 0} #Need to fix this
               ]
               obj.obj_name='CTraceReference'
               trace=Datalog.map_data(ConfigParam.get_value(ConfigParam::StartFreq),ConfigParam.get_value(ConfigParam::StopFreq),
                  anl.start_freq, anl.stop_freq,selected_profile.trace,500,anl.attenuator-1)#Make the default value 1 less than the attenuation.
               if trace.length != 500
                  raise "Failed on Trace Generation, trace is #{trace.length}"
               end
               trace_array=trace.collect { |val|
                  ((val-anl.attenuator)*1024.0/70.0+1023).round
               }
               obj.attenuation=anl.attenuator
               obj.trace=trace_array
               reference_list.push(obj)
            }
         }
         return reference_list
      end
      def TraceReferenceFO::specRead(f, obj_name)
         trace_ref=TraceReferenceFO.new(obj_name)
         data_str=f.read(1168)
         data=data_str.unpack(Signature)
         raise "Wrong count #{data.length} .expected 19" if (data.length !=19)
         trace_ref.name=data[0]
         trace_ref.comment=data[1]
         trace_ref.tm=data[2]
         trace_ref.temp_external=data[3]
         trace_ref.current_mode=data[4]
         trace_ref.attenuation=data[5]
         trace_ref.if_offset=data[6]
         trace_ref.ref_offset=data[7]
         trace_ref.center_freq=data[8]
         at2000status_str=data[9]
         status_data=at2000status_str.unpack(StatusSigSA)
         if (StatusLabelsSA.length != status_data.length)
            raise("Incorrect size of status#{status_data.length}/"+
               StatusLabelsSA.length.to_s) 
         end
         StatusLabelsSA.each_index { |label_idx|
            trace_ref.at2000status[StatusLabelsSA[label_idx]]=status_data[label_idx]
         }
         trace_ref.trace=Common.parse_image(data[10])
         trace_ref.user=data[11]
         trace_ref.swcomment=data[12]
         trace_ref.company_name=data[13]
         trace_ref.software_ver=data[14]
         trace_ref.cal_date=data[15]
         trace_ref.model_nbr=data[16]
         #trace_ref.reserved=data[17]
         trace_ref.trace_comment=data[17]
         threshold_count=data[18]
         threshold_count.times { |idx|
            thresh_str=f.read(3)
            thresh_data=thresh_str.unpack("sc")
            thresh={:offset=>thresh_data[0], :type=>thresh_data[1]}
            trace_ref.thresh_list.push(thresh)
         }
         return trace_ref
      end

   end

   #####################################################################################
   ###
   ###Switch File Object
   ###
   ################
   class SwitchesFO < FileObj
      attr_reader :serial_port_nbr,:baud_rate,:stacking,:switch_type,
         :bidirectional_flag, :master_switch_flag, 
         :switch_list, 
         :rptp_list
      attr_writer :serial_port_nbr,:baud_rate,:stacking,:switch_type,
         :bidirectional_flag, :master_switch_flag, 
         :switch_list, #Keys=[switch_name, port_nbr, port_count]
         :rptp_list #Keys=[rptp_name]
      def write(f)
         data_str=[@serial_port_nbr,@baud_rate,@rptp_list.length,@stacking, @switch_type,
            @bidirectional_flag, @master_switch_flag,@switch_list.length].pack('CCSCCCCC')
         f.write(data_str)
         @switch_list.each {|switch|
            f.write([switch[:switch_name],0,switch[:port_nbr],switch[:port_count]].pack('a10CSC'))
         }
         @rptp_list.each {|rptp|
            f.write([rptp[:rptp_name]].pack('a41'))
         }

      end
      def SwitchesFO::build(analyzer_id, obj_name='CSwitchNetwork')
         dbrec=nil
         tried=0
         begin
            tried+=1
            dbrec=Analyzer.find(analyzer_id)
         rescue Exception => e
            if (tried <=2)
               Analyzer.connection.reconnect!()
               retry
            else
               raise(e)
            end
         end
         switch_net=SwitchesFO.new( obj_name)
         switch_net.serial_port_nbr=dbrec.port_nbr
         switch_net.baud_rate=dbrec.baud_rate
         switch_net.stacking=0
         switch_net.switch_type=dbrec.switch_type
         switch_net.bidirectional_flag= dbrec.bidirectional_flag ? 1 : 0
         #rptp_count=rec_data[2]
         switch_count=dbrec.switches.count()
         if (dbrec.switches.count(:conditions=>"master_switch_flag=1")==0)
            switch_net.master_switch_flag=0
         else
            switch_net.master_switch_flag=1
         end
         switch_list=[]
         rptp_list=[]
         idx=0
         dbrec.switches.find(:all, :order=>" address ").each { |switch|
            idx=idx+1
            switch_list.push(
               {:switch_name=>switch[:switch_name], :port_nbr=> switch[:address], :port_count=>switch[:port_count]})

            switch.switch_ports.find(:all, :order=>"port_nbr").each {  |switch_port|
               rptp_list.push({:rptp_name=>switch_port[:name]})
            }
         }
         switch_net.switch_list=switch_list
         switch_net.rptp_list=rptp_list
         return [switch_net]
      end
      def SwitchesFO::specRead(f, obj_name)
         switch_net=SwitchesFO.new( obj_name)
         #port(B),speed(b),rptp(w),stacking(b),switch_type(b),bidirectional(b),master_switch_flag(b)
         #nbr_of_switches(b)
         rec_data=f.read(9).unpack('CCSCCCCC')
         switch_net.serial_port_nbr=rec_data[0]
         switch_net.baud_rate=rec_data[1]
         rptp_count=rec_data[2]
         switch_net.stacking=rec_data[3]
         switch_net.switch_type=rec_data[4]
         switch_net.bidirectional_flag=rec_data[5]
         switch_net.master_switch_flag=rec_data[6]
         switch_count=rec_data[7]
         switch_list=[]
         rptp_list=[]
         switch_count.times { |switch_idx|
            rec_data_str=f.read(14)
            raise("Switch data not right @ #{switch_idx}") if (rec_data_str.nil? || rec_data_str.length!= 14)
            rec_data=rec_data_str.unpack('A11SC')
            switch_list.push(
               {:switch_name=>rec_data[0], :port_nbr=> rec_data[1], :port_count=>rec_data[2]})
         }
         switch_net.switch_list=switch_list
         rptp_count.times { |rptp_idx|
            rec_data_str=f.read(41)
            raise("Switch data not right @ #{switch_idx}") if (rec_data_str.nil? || rec_data_str.length!= 41)
            rec_data=rec_data_str.unpack('A41')
            rptp_list.push(
               {:rptp_name=>rec_data[0]})
         }
         switch_net.rptp_list=rptp_list
         return switch_net
      end
      def initialize( obj_name)
         @schema=SWITCH_SCHEMA
         @obj_name=obj_name
      end
   end
end
