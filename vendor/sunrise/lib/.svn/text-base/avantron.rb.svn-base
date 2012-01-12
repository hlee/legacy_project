# =Avantron Module.
# Contains the code for the interface to the Avantron protocol.

#$:.push(File.expand_path(File.dirname(__FILE__)))
#require 'common'
#require 'monitoring_files'
require 'logger'
require 'errors'


module Avantron
   #   include MonitorFiles
# ==AvantronRec
# The AvantronRec represents a Avantron Protocol packet that has been recieved or sent.
   class AvantronRec
      attr_reader :source, #Source component of packet
      :destination, #Destination component of packet
      :msg_type,           #Msg type component of packet
      :node_nbr,           #Node for packet,  I don't think this is being used.
      :packet_seq,         #Packet sequence number.  Again stuff not being used.
      :msg_len,            #Length of message component of packet
      :msg,                #Message portion of packet in string form.  Depends on message type.
      :msg_object,         #Pased message string.
      :from_analyzer       #A flag from whether the message is from the analyzer or not.  (rename to 'from_server')
      attr_writer :msg,    #Need to be able to create a message.
      :msg_object,         #Need to be able to create a msg object.
      :logger              #Log Object

      # ===msg_label
      # <b>Public Function</b>
      # Returns the text string for this message type.
      def msg_label()
         type_label= @@msg_types[@msg_type][:TypeLabel]
         if (type_label.is_a?(String))
            return type_label
         else
            return type_label.call(self)
         end
      end
 
      # ===msg_obj()
      # <b>Public Function</b>
      # Generates the msg_object from the msg if it does not exist. Otherwise returns msg_obj.
      def msg_obj()
         source=:FromClient
         if (from_analyzer)
            source= :FromServer
         end
         if @msg_object.nil? || @msg_object.empty?() #else we just return the msg_object
            if !@@msg_types[@msg_type].key?(:ParseMsg) || @@msg_types[@msg_type][:ParseMsg].nil?
               if (@@msg_types[@msg_type].key?(:Format) && @@msg_types[@msg_type].key?(:Keys) )
                  @msg_object=unpack(@@msg_types[@msg_type])
                  if @msg_object.nil?
                     raise ProtocolError.new("Unable to build message object")
                  end
               else
                  raise ProtocolError.new("No Parsing Function or Format defined for #{@msg_type} ")
               end
            else
               parseMsg=@@msg_types[@msg_type][:ParseMsg]
               parseMsg.call(self)
            end
         end
         return @msg_object
      end

      # ===msg_str()
      # <b>Public Function</b>
      # Generates the msg from the msg_object if it does not exist. Otherwise just returns msg.
      def msg_str()
         source=:FromClient
         if (from_analyzer)
            source= :FromServer
         end
         if @msg.nil? || @msg.empty?() #else we just return @msg
            if !@@msg_types[@msg_type].key?(:BuildMsg) || @@msg_types[@msg_type][:BuildMsg].nil?
               if (@@msg_types[@msg_type].key?(:Format) && @@msg_types[@msg_type].key?(:Keys) )
                  @msg=pack(@@msg_types[@msg_type])
                  if @msg.nil?
                     raise ProtocolError.new("Unable to build submessage")
                  end
               else
                  raise ProtocolError.new("No Build Function or Format defined for #{@msg_type} ")
               end
            else
               buildMsg=@@msg_types[@msg_type][:BuildMsg]
               @msg=buildMsg.call(self)
            end
         end
         return @msg
      end

      # ===unpack(cmd_hash)
      # <b>Private Function</b>
      # For Unpacking/parsing a message according to the cmd_hash
      # cmd_hash - A hash that contains:
      # * :Format - A pack/unpack string.
      # * :Keys   - An array of strings that will be the keys in the msg_obj.  These keys
      #             will be in order of the corresponding values unpacked from the format string.
      # * Returns the msg_object generated from the string.
      def unpack(cmd_hash)
         #if (@cmd_hash.nil?)
         #   raise ProtocolError.new("cmd_hash is nil in unpack")
         #end
         @msg_object=Hash.new()
         if (cmd_hash.key?(:Format) && cmd_hash.key?(:Keys))
            if @msg.nil?
               @msg_object=nil
               return nil
            end
            value_list=@msg.unpack(cmd_hash[:Format])
            key_list=cmd_hash[:Keys]
            key_list.each_index { |index|
               @msg_object[key_list[index]]=value_list[index]
            }
            return @msg_object
         else
            @logger.error(cmd_hash.inspect())
            raise ProtocolError.new("unpack requires Keys and Format")
         end
      end

      # ===pack(cmd_hash)
      # <b>Private Function</b>
      # For packing/generating a message according to the cmd_hash
      # cmd_hash - A hash that contains:
      # * :Format - A pack/unpack string.
      # * :Keys   - An array of strings that are  the keys in the msg_obj.  These keys
      #             will be in order of the corresponding values stored in the string.
      # * Returns the msg generated from the string.
      def pack(cmd_hash)
         msg_obj()

         if (cmd_hash.key?(:Format) && cmd_hash.key?(:Keys))
            if @msg_object.nil?
               @msg=nil
               return nil
            end
            key_list=cmd_hash[:Keys]
            value_list=Array.new()
            key_list.each { |key|
               if !@msg_object.key?(key)
                  raise ProtocolError.new("Key: '#{key}' not found in msg_object... see: #{@msg_object.inspect()}")
               end
               value_list.push(@msg_object[key])
            }
            format = cmd_hash[:Format]
            if (format.nil? && value_list.empty?)
               submsg=''
            else
               submsg=value_list.pack(format)
            end
            return submsg;
         else
            @logger.error(cmd_hash.inspect())
            raise ProtocolError.new("unpack requires Keys and Format")
         end
      end

      # ===label_complex_command(cmd)
      # <b>Private Function</b>
      # Determines whether to use the unpack mechanism or calls a function to parse the message.
      def label_complex_command(command)
         if (!command.nil?)
            if (@from_analyzer)
               if command.key?(:FromServer)
                  return command[:FromServer][:Label]
               else
                  raise ProtocolError.new("Server Command not supported.#{command.inspect()}")
               end
            else
               if command.key?(:FromClient)
                  return command[:FromClient][:Label]
               else
                  @logger.error(command.inspect())
                  raise ProtocolError.new("Client Command not supported.#{command.inspect()}")
               end
            end
         else
            return "COMPLEX COMMAND IS NIL"
         end
      end
      # ===complex_command(cmd)
      # <b>Private Function</b>
      # Determines whether to use the unpack mechanism or calls a function to parse the message.
      def complex_command(command)
         if (!command.nil?)
            if (@from_analyzer)
               if command.key?(:FromServer)
                  cmd=command[:FromServer]
               else
                  raise ProtocolError.new("Server Command not supported.#{command.inspect()}")
               end
            else
               if command.key?(:FromClient)
                  cmd=command[:FromClient]
               else
                  @logger.error(command.inspect())
                  raise ProtocolError.new("Client Command not supported.#{command.inspect()}")
               end
            end
         else
            raise ProtocolError.new("I don't recognize command #{command.inspect()} for Msg Type #{msg_label()}")
         end
         if (cmd.key?(:ParseMsg) )
            return cmd[:ParseMsg].call(self)
         elsif (cmd.key?(:Format) && cmd.key?(:Keys))
            return unpack(cmd)
         else
            raise ProtocolError.new("No Way to parse Msg Type #{msg_label()}")
         end
      end
      # ===general_label
      # <b>Private Function</b>
      # For displaying message for <i>msg_type=20</i> messages.
      def general_label()
         if @msg.nil?
            return "GENERAL MSG [UNKNOWN]"
         else
            return label_complex_command(@@general_commands[@msg[2].to_s()])
         end
      end
      # ===general_msg
      # <b>Private Function</b>
      # For parsing general <i>msg_type=20</i> messages.
      def general_msg()
         return complex_command(@@general_commands[@msg[2].to_s()])
      end
      # ===build_general_msg
      # <b>Private Function</b>
      # For building general <i>msg_type=20</i> messages.
      def build_general_msg()
         subcommand=@msg_object['subcommand']
         return build_complex_command(@@general_commands[subcommand.to_s()])
      end

      # ===build_complex_command(cmd)
      # <b>Private Function</b>
      # Determines whether to use the pack mechanism or calls a function to parse the message.
      def build_complex_command(command)
         if (!command.nil?)
            if (@from_analyzer)
               if command.key?(:FromServer)
                  cmd=command[:FromServer]
               else
                  @logger.error(command.inspect())
                  raise ProtocolError.new("Server Command not supported.")
               end
            else
               if command.key?(:FromClient)
                  cmd=command[:FromClient]
               else
                  @logger.error(command.inspect())
                  raise ProtocolError.new("Client Command not supported.")
               end
            end
         else
            raise ProtocolError.new("I don't recognize command #{command} for Msg Type #{msg_label()}")
         end
         if (cmd.key?(:BuildMsg) )
            return cmd[:BuildMsg].call(self)
         elsif (cmd.key?(:Format) && cmd.key?(:Keys))
            return pack(cmd)
         else
            raise ProtocolError.new("No Way to parse Msg Type #{msg_label()}")
         end

      end
      # ===qam_label_label
      # <b>Private Function</b>
      # For displaying message for <i>msg_type=7</i> messages.
      def qam_label()
         if @msg.nil?
            return "MONITOR [UNKNOWN]"
         end
         return label_complex_command(@@qam_commands[@msg[2].to_s()])
      end
      # ===parse_qam()
      # <b>Private Function</b>
      # This parses the msg portion of QAM Packets<i>(msg_type=7)</i> .
      def parse_qam()
         if (@@qam_commands[@msg[2].to_s()].nil?)
            raise ProtocolError.new("No Command for #{@msg[0].to_s()}")
         end
         return complex_command(@@qam_commands[@msg[2].to_s()])
      rescue Exception =>e
         raise ProtocolError.new(e)
      end

      # ===build_qam()
      # <b>Private Function</b>
      # This builds the msg portion of QAM Packets<i>(msg_type=90)</i> .
      def build_qam()
         subcommand=@msg_object[:subcommand]
         if !@@qam_commands.key?(subcommand.to_s())
            raise ProtocolError.new("Cannot find |#{subcommand.to_s()}| in qam_commands list")
         end
         return build_complex_command(@@qam_commands[subcommand.to_s()])
      end
      # ===monitor_label_label
      # <b>Private Function</b>
      # For displaying message for <i>msg_type=90</i> messages.
      def monitor_label()
         if @msg.nil?
            return "MONITOR [UNKNOWN]"
         end
         return label_complex_command(@@remote_commands[@msg[0].to_s()])
      end
      # ===monitor()
      # <b>Private Function</b>
      # This parses the msg portion of Monitoring Packets<i>(msg_type=90)</i> .
      def monitor()
         if (@@remote_commands[@msg[0].to_s()].nil?)
            raise ProtocolError.new("No Command for #{@msg[0].to_s()}")
         end
         return complex_command(@@remote_commands[@msg[0].to_s()])
      rescue Exception =>e
         @logger.debug e.backtrace()
         raise ProtocolError.new(e)
      end

      # ===build_monitor()
      # <b>Private Function</b>
      # This builds the msg portion of Monitoring Packets<i>(msg_type=90)</i> .
      def build_monitor()
         subcommand=@msg_object['subcommand']
         if !@@remote_commands.key?(subcommand.to_s())
            raise ProtocolError.new("Cannot find |#{subcommand.to_s()}| in remote_commands list")
         end
         return build_complex_command(@@remote_commands[subcommand.to_s()])
      end

      # ===parse_switch_msg()
      # <b>Private Function</b>
      # This parses the msg portion of Switch Packets<i>(msg_type=80)</i> .
      def parse_switch_msg()
         subcommand=@msg[2]+@msg[3]*256
         if (subcommand>=32768)
            return complex_command(@@switch_commands[subcommand.to_s()])
         else
            return complex_command(@@switch_commands['ELSE'])
         end
      end
      # ===switch_label
      # <b>Private Function</b>
      # For displaying message for <i>msg_type=90</i> messages.
      def switch_label()
         if (@msg_object.key?('subcommand'))
            subcommand=[@msg_object['subcommand']]
            return label_complex_command(@@switch_commands[subcommand.to_s()])
         else
            return label_complex_command(@@switch_commands['ELSE'])
         end
      end

      # ===build_switch_msg()
      # <b>Private Function</b>
      # This builds the msg portion of Switch Packets<i>(msg_type=80)</i> .
      def build_switch_msg()
         if (@msg_object.key?('subcommand'))
            subcommand=[@msg_object['subcommand']]
            return build_complex_command(@@switch_commands[subcommand.to_s()])
         else
            return build_complex_command(@@switch_commands['ELSE'])
         end
      end


      # ===response?()
      # <b>Private Function</b>
      # A temporary (hopefully) hack
      def response?()
         if @msg_len > 600
            return true
         else
            return false
         end
      end
      # ===@@@msg_types
      # <b>Private HASH</b>
      # Stores the formats for the basic message types.
      @@msg_types = {
         '00'=> { :TypeLabel=>'RESERVED', :ParseMsg=>nil},
         '01'=> { :TypeLabel=>'ACK', :Format=>"C",:Keys=>['retcode']},
         '02'=> { :TypeLabel=>'NACK', :Format=>"C",:Keys=>['errorcode']},
         '03'=> { :TypeLabel=>'LOGON', :Format=>"C",:Keys=>['resv1']},
         '04'=> { :TypeLabel=>'LOGOFF',:Format=>"",:Keys=>[] },
         '05'=> { :TypeLabel=>'IMAGE_SPEC', :Format=>'Ca625',:Keys=>['client','aligned_image']},
         '06'=> { :TypeLabel=>'CTRL_SPECTRUM', :ParseMsg=>nil},
         '07'=> { :TypeLabel=>'QAM', :ParseMsg=>lambda{ |obj| obj.parse_qam()}, :BuildMsg=>lambda { |obj| obj.build_qam()}},
         '08'=> { :TypeLabel=>'DCP', :Format=>"SCCD", :Keys=>['len','do_measures','resv','meas_result']},
         '09'=> { :TypeLabel=>'TDMA', :ParseMsg=>nil},
         '10'=> { :TypeLabel=>'SM2', :Format=>"SCCS"+"CCSCCLLs",:Keys=>['len','subcommand','resv','channel_nbr',
            'channel_plan_flag','resv2','channel_nbr','active_status','chan_type','chan_freq','meas_freq','meas_amp',
            'channel_plan_flag_2','resv3','channel_nbr_2','active_status_2','chan_type_2','chan_freq_2','meas_freq_2','meas_amp_2']
               },
         '11'=> { :TypeLabel=>'AUTO_TEST', :ParseMsg=>nil},
         '12'=> { :TypeLabel=>'DM', :Format=>"SCCss",:Keys=>['pkt_len','subcommand','resv','ratio','modulation']},
         '13'=> { :TypeLabel=>'NI', :ParseMsg=>nil},
         '20'=> { :TypeLabel=>lambda {|obj|'GENERAL_COMMAND ['+ obj.general_label() + ']'},
            :ParseMsg=>lambda {|obj| obj.general_msg()},
            :BuildMsg=>lambda{|obj| obj.build_general_msg()}
         },
         '25'=> { :TypeLabel=>'NEW_TRACE_MESSAGE', :ParseMsg=>nil},
         '50'=> { :TypeLabel=>'XML_MESSAGE', :ParseMsg=>nil},
         '79'=> { :TypeLabel=>'REMOTE_TCP/IP_COMMAND', :ParseMsg=>nil},
         '80'=> { :TypeLabel=>lambda {|obj| 'SWITCH_NETWORK [' + obj.switch_label() + ']'},
            :ParseMsg=>lambda{|obj| obj.parse_switch_msg()},
            :BuildMsg=>lambda{|obj| obj.build_switch_msg()}
         },
         '89'=> { :TypeLabel=>'POLLING', :ParseMsg=>nil},
         '90'=> { :TypeLabel=>lambda {|obj| 'MONITORING [' + obj.monitor_label() + ']'},
            :ParseMsg=>lambda {|obj| obj.monitor()},
            :BuildMsg=>lambda{|obj| obj.build_monitor()}
         },
         #'90'=> { :TypeLabel=>'MONITORING', :ParseMsg=>lambda {|obj| $LOG.debug obj} },
         '91'=> { :TypeLabel=>'SYSTEM_ERROR', :Format=>'C',:Keys=>['resv1']},
         '92'=> { :TypeLabel=>'DISK_ERROR', :Format=>'SLC*',:Keys=>['disk_usage','supplementary_data','text_msg']},
         '93'=> { :TypeLabel=>'SWITCH_ERROR', :Format=>'C',:Keys=>['resv1']},
         '94'=> { :TypeLabel=>'NEW_MODE', :Format=>"C", :Keys=>['desiredmode']},
         # DEPRECATED '95'=> { :TypeLabel=>'UPDATE_SOFTWARE', :ParseMsg=>nil},
         '96'=> { :TypeLabel=>'BATT_LOW',:Format=>'E',:Keys=>['battery_level'] },
         '97'=> { :TypeLabel=>'SHUTOFF_SERVER', :Format=>"",:Keys=>[]},
         '98'=> { :TypeLabel=>'TRIGGER', :Format=>'CC',:Keys=>['trace_count_to_perform','acquisition_buffer_reset']},
         '99'=> { :TypeLabel=>'GET_PARAM_SYSTEM',  #5.3.13
            :Format=>'a30a30a12a13a21'+'a11a11a11a11'+'a11a11a12a11a44'+'CCCCC'+'SSSS'+'SSE',
            :Keys=>[
               'user_name','company_name','softare_ver','calibration_date','calibration_site',
               'sn_system','sn_power','sn_attenuator','sn_l01',
               'sn_dds','sn_logamp','sn_digital_card','sn_front_end','resv1',
               'interne1','interne2','Invalid_key_beepy_switch','power_off_beep_switch','help_file_switch',
               'printer_type','date_format','lcd_power_down_delay','at2000_power_off_delay',
               'resv2','resv3','resv4'
            ]
         }
      }
      # ===@@@remote_commands
      # <b>Private HASH</b>
      # Stores the formats for the submessage remote(msg_type=7) commands.
      QAM_PREFIX_FORMAT="SCCSL"+"FFSSS"+"LLLL"+"CCCC"
      @@qam_prefix_keys=[:hdr_len,:disp_type,:polarity,:opt_att,:real_rate,:ber_pre,:ber_post,:mer,
         :enm,:evm,:es,:ses,:fls,:resv,:symb_lock,:fwd_err_lock,:stream_lock,:resv2]
      @@qam_commands =
      {
         "0"=> {
            :FromServer=>
            {
               :Label=>"Constellation",
               :Format=>QAM_PREFIX_FORMAT + "Sa*",
               :Keys=>@@qam_prefix_keys + [:point_count,:points]
            }
         },
         "1"=> {
            :FromServer=>
            {
               :Label=>"Statistic",
               :Format=>QAM_PREFIX_FORMAT + "LFF",
               :Keys=>@@qam_prefix_keys + [:point_count,:ber_pre, :ber_post]
            }
         },
         "2"=> {
            :FromServer=>
            {
               :Label=>"EQUALIZER",
               :Format=>QAM_PREFIX_FORMAT + "CCS*",
               :Keys=>@@qam_prefix_keys + [:pre_tap,:post_tap,:points]
            }
         },
         "3"=> {
            :FromClient =>
            {
               :Label=>'Start Diagnostic',
               :Format=>'SCCCCCCCCCCCCCCCCCCa10',
               :Keys=>[:hdr_len, :subcommand, :resv,:power_flag,:mer_flag, :enm_flag, :evm_flag, :sys_noise_flag, :cw_infc_flag, :freq_resp_flag,
                  :margin_flag, :margin_tap_flag, :compression_flag, :digital_hum_flag, :phase_noise_flag, :IQ_gain_diff_flag, :iq_phase_diff_flag, 
                  :carrier_flag, :symbol_rate_flag,:resv2]
            },
            :FromServer=>
            {
               :Label=>"DIAGNOSTIC",
               :Format=>QAM_PREFIX_FORMAT + "CCS"+"lllllllllllllll"+"a128"+"CCCCCCCCCCCCCCCC"+"a32",
               :Keys=>@@qam_prefix_keys + [:resv,:dig_error_type,:resv1,
                  :mer,:enm,:evm,:sys_noise,:cw_inter,:freq_resp,:echo_margin,:echo_margin_tap,:compression,
                     :dig_hum,:phase_noise,:iq_gain_diff, :iq_phase_diff,:carrier_offset,:symbol_rate_ppm,
                  :resv,
                  :pwr_flg,:mer_flg,:enm_flg,:sys_noise_flg,:system_noise_flag, :cw_inter_flag, :freq_resp_flag, :echo_margin_flag,:echo_mrg_tap_flag,
                     :compression_flag,:dig_hum_flag,:phase_noise_flag, :iq_gain_diff_flag,:iq_phase_diff_flag, :symbol_rate_ppm_flag,
                  :resv2]
            }
         }
      }
      # ===@@@remote_commands
      # <b>Private HASH</b>
      # Stores the formats for the submessage remote(msg_type=90) commands.
      @@remote_commands =
      {
         "1"=> {
            :FromClient=>
            {
               :Label=>"Start Monitoring",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "2"=> {
            :FromClient=>
            {
               :Label=>"Stop Monitoring",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "3"=> {
            :FromClient=>
            {
               :Label=>"Pause Monitoring",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "4"=> {
            :FromClient=>
            {
               :Label=>"Ping",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "5"=> {
            :FromClient=>
            {
               :Label=>"Download Database",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "6"=> {
            :FromClient=>
            {
               :Label=>"Upload Database",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "7"=> {
            :FromClient=>
            {
               :Label=>"Poll Status",
               :Format=>"CC",
               :Keys=>["subcommand",'resv1']
            }
         },
         "8"=> {
            :FromClient=>
            {
               :Label=>"Delete Alarms",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "9"=> {
            :FromClient=>
            {
               :Label=>"Delete Statistics",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "10"=> {
            :FromClient=>
            {
               :Label=>"Delete Integrals",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "11"=> {
            :FromClient=>
            {
               :Label=>"Next Alarm",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "12"=> {
            :FromClient=>
            {
               :Label=>"Next Statistic",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "13"=> {
            :FromClient=>
            {
               :Label=>"Next Integral",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "14"=> {
            :FromClient=>
            {
               :Label=>"Reset Error",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "15"=> {
            :FromClient=>
            {
               :Label=>"Get Serial",
               :Format=>"CC",
               :Keys=>["subcommand",'resv1'],
            },
            :FromServer => {
               :Label=>"Get Serial",
               :Format=>"CCLLL",
               :Keys=>["subcommand",'resv1',"tp_sn","tp_vn","sn"]
            }
         },
         "16"=> {
            :FromClient=>
            {
               :Label=>"Select Requested",
               :Format=>"CCS",
               :Keys=>["subcommand","status","src_nbr"]
            }
         },
         #TODO - SEND REQUESTED
         "17"=> {
            :FromClient=>
            {
               :Label=>"Set Working Mode",
               :Format=>"CC",
               :Keys=>["subcommand","mode_on"]
            }

         },
         "18"=> {
            :FromClient=>
            {
               :Label=>"Get Source Sequence",
               :Format=>"CC",
               :Keys=>["subcommand",'resv1'],
            },
            :FromServer => {
               #TODO Variable Length
               :Format=>nil,
               :Keys=>nil,
            }

         },
         "19"=> {
            :FromClient=>
            {
               :Label=>"Get Source Settings",
               :Format=>"CCS",
               :Keys=>["subcommand",'resv1',"signal_source"],
            },
            :FromServer => {
               :Label=>"Reply Get Source Settings",
               :Format=>"CCSCCCCsSsDDSSSSDDDSCCCCSCCCCCCDDSS",
               :Keys=>["subcommand",'resv1',"signal_source","resv2","monitoring_mode","resv3","resv4",
                  "external_temp","attenuator_value","IF","cen_freq","span","zero_span","vid_chan","aud_chan",
                  "sweep_time","horz_time","res_bw","video_bw","resv5","avg_type","v2_noise_marker","fm_horz_marker",
                  "resv6","vertical_scale","audio_volume","trigger_type","vert_mrk_1_disp","vert_mrk2_disp",
                  "horz_mrk1_disp","horz_mrk2_disp","vert_mrk1_pos","vert_mrk2_pos","horz_mrk1_pos","horz_mrk2_pos"
               ]
            }
         },
         "20"=> {
            :FromClient=>
            {
               :Label=>"Set Throttling Values",
               :Format=>"CCCC",
               :Keys=>["subcommand",'resv1',"min_cpu_for_monitoring", "max_live_frame_rate"]
            }
         },
         "21"=> {
            :FromClient=>
            {
               :Label=>"Get Alarm Threshold",
               :Format=>"CCS",
               :Keys=>["subcommand",'resv1',"signal_nbr"],
            },
            :FromServer=>{
               :Format=>"CCSCCsCsCsCsCsCa625",
               :Keys=>["subcommand","status","signal_source",'resv1',"num_of_alarm_threshold",
                  "threshold1","compare_type1",
                  "threshold2","compare_type2",
                  "threshold3","compare_type3",
                  "threshold4","compare_type4",
                  "threshold5","compare_type5",
               "trace_image"]
            }
         },
         "22"=> {
            :FromClient=>
            {
               :Label=>"Next Alarm32",
               :Format=>"C",
               :Keys=>["subcommand"]
            }
         },
         "23"=> {
            :FromClient=>
            {
               :Label=>"FloodConfig",
               :Format=>"CLLL",
               :Keys=>["subcommand","cycle_count","alarm_flood_thresh","flood_restore_cycle"]
            }
         },
         "45"=> {
            :FromServer=>
            {
               :Label=>"STATUS",
               :Format=>"CSSSCC",
               :Keys=>["subcommand","alarm_count","statistic_count","integral_count","monitoring_status","error_nbr"]
            }
         },
         "46"=> {
            :FromServer=>
            {
               :Label=>"Alarm Monitoring with Imaging",
               :Format=>"CLSCCSCCCCCCCSsSa8",
               :Keys=>["subcommand","sn_schedule","step_nbr","monitoring_mode","calibration_status",
                  "event_year","event_month","event_day","event_hour","event_minute","event_second","sec_hundreths",
               "alarm_level","alarm_deviation","event_extern_temp","numb_of_xmit_alarms",'resv1']
            }
         },
         "47"=> {
            :FromServer=>
            {
               :Label=>"Alarm Monitoring With Imaging",
               :Format=>"CLSCC"+"SCCCCCC"+"CSsSa8a*",
               :Keys=>["subcommand","sn_schedule","step_nbr","monitoring_mode","calibration_status",
                  "event_year","event_month","event_day","event_hour","event_minute","event_second","sec_hundreths",
               "alarm_level","alarm_deviation","event_extern_temp","numb_of_xmit_alarms",'resv1',"trace"]
            }
         },
         "48"=> {
            :FromClient=>
            {
               :Label=>"Statistic",
               :Format=>"CLSCCSCCCCCCa3sSCa*",
               :Keys=>["subcommand","sn_schedule","step_nbr","monitoring_mode","calibration_status",
                  "event_year","event_day","event_hour","event_minute","event_second","sec_hundreths",
               'resv1',"event_extern_temp","numb_of_xmit_stastics","resv2","trace"]
            }
         },
         "49"=> { #5.5.37
            :FromServer =>
            {
               :Label =>"Alarm Monitoring with Imaging multimode",
               :ParseMsg => lambda { |obj|
                  first=true
                  caller.each { |c|
                     first=false
                  }
                  recPrefix= 'CLLS'+'CCS'+'CCCCCCC'+ 'sS'+'LLLL'+'a16a*'
                  labels=['alarm_code','sn_schedule','ver_of_sched','step_nbr',
                     'monitoring_mode','calibration_status','event_year',
                     'event_month','event_day','event_hour','event_minute','event_second','sec_hundreths','alarm_level',
                     'external_temp','numb_of_xmit_alarms',
                  'sn_signal_src','sn_profile','ver_profile','resv1','alarm_result']
                  obj.unpack({:Label=>'alarm func', :Keys=>labels, :Format=>recPrefix})
                  if obj.msg_len ==683
                     #image=obj.parse_image(obj.msg[58..682])
                     obj.msg_object['trace']=obj.msg[58..682]

                  else
                     obj.msg_object['test_results']=Array.new()
                     testCount=obj.msg[58]+obj.msg[59]*256
                     loc=0
                     testCount.times { |index|
                        loc=60+7*index
                        testValues=obj.msg[loc..loc+6].unpack('SCL')
                        test={
                           :TestNumber=>testValues[0],
                           :AlarmLevel=>testValues[1],
                           :TestValue=>testValues[2]
                        }
                        obj.msg_object['test_results'].push(test)
                     }
                     if ((loc+6)>(testCount*7+65))
                        raise ProtocolError.new("indexes are out of sync;Loc=#{loc}, Test Count=#{testCount}")
                     end

                  end
               },
               :BuildMsg=>lambda {|obj|
                  recPrefix= 'CLLS'+'CCS'+'CCCCCCC'+ 'sS'+'LLLL'+'a16a*'
                  labels=['alarm_code','sn_of_sched','ver_of_sched','step_number',
                     'monitor_mode_nbr','calibration_status','event_year',
                     'month','day','hour','minute','second','hundreths','alarm_level',
                     'external_temp','not_transferred_alarm_count',
                  'sn_signal_src','sn_profile','ver_profile','resv1','alarm_result']
                  obj.pack({:Label=>'alarm func', :Keys=>labels, :Format=>recPrefix})
                  if (obj.msg_object.key?('image'))
                     raise ProtocolError.new('TODO I have not wrote the code to generate the image yet')
                  elsif (obj.msg_object.key?('test_results'))
                     raise ProtocolError.new('TODO I have not wrote the code to generate the test results yet')
                  else
                     raise ProtocolError.new('Neither test_results or image is defined for the Alarm Monitoring with image')
                  end
               }
            }
         }

      }
      # ===@@setting_recs
      # <b>Private HASH</b>
      # Stores the formats for the submessage remote(msg_type=80,submsg=1,2) settings commands.
      @@setting_recs= {
         "SA"=> {
            :Format => "SCCC"+"CCCsSs"+"EESSSS"+"EEES"+"CCCCSCC"+"CCCC"+"EESS",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
               "actual_mode","resv3","resv4","external_temp","attenuator","internal_freq",
               "central_freq","span","zero_span","video_chan","audio_chan","sweep_time",
               "horizontal_time","resolution_bw","video_bw","resv5",
               "avg_type","v2_is_noise_mark","fm_horz_mark","resv6","vert_scale","audio_volume","trigger_type",
               "vert_mark_1_disp","vert_mark_2_disp","horz_mark_1_disp","horz_mark_2_disp",
            "vert_mark_1","vert_mark_2","horz_mark_1","horz_mark_2"]

         },
         "DCP"=> {
            :Format => "SCCC" + "CCCsE"+"ssssE",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
               'actual_mode','resv3','resv4',"attenuator",'central_freq',
            'video_chan','audio_chan','vert_scale','avg_type','bw']
         },
         "QAM"=> {
            :Format => "SCCC"+"CCCCC"+"SeeSES"+"CCLL"+"CCCCCC"+"LCCCC"+"LL",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2", #4
               'actual_mode','version','standard_type','modulation_type','polarity', #5
               'mer_thresh','preber_thresh','postber_thress','attenuator','central_freq','channel_providing', #6
               'chplan_usage','nnn_correction','ideal_symbol_rates','ses_thresh', #4
               'display_type','grid_status','template_status','interleave_i','interleave_j','filter_type', #6
               'stat_len_or_filter_size','start_stats','zoom_type','first_zoom_lvl_quad','second_zoom_lvl_quad', #5
               'high_filter','low_filter' #2
            ]
         },
         "SM"=> {
            :Format => "SCCC" + "CCCsSs" +"a8CCs" + "CCEss"   , #45
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2", #4
               'actual_mode','resv1','resv2','external_temp','attenuator','internal_freq', #6
               "resv3","current_carrier_nbr","measured_carrier_nbr","vertical_scale", #4
               "measure_type_1","active_carrier_1","central_freq_1","video_chan_1","audio_chan_1", #5
            ]
         },
         "SM6"=> {
            :Format => "SCCC" + "CCCsSs" +"a8CCs" + "CCEss" + "CCEss" + "CCEss" + "CCEss" + "CCEss" + "CCEss" , #45
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2", #4
               'actual_mode','resv1','resv2','external_temp','attenuator','internal_freq', #6
               "resv3","current_carrier_nbr","measured_carrier_nbr","vertical_scale", #4
               "measure_type_1","active_carrier_1","central_freq_1","video_chan_1","audio_chan_1", #5
               "measure_type_2","active_carrier_2","central_freq_2","video_chan_2","audio_chan_2", #5
               "measure_type_3","active_carrier_3","central_freq_3","video_chan_3","audio_chan_3", #5
               "measure_type_4","active_carrier_4","central_freq_4","video_chan_4","audio_chan_4", #5
               "measure_type_5","active_carrier_5","central_freq_5","video_chan_5","audio_chan_5", #5
               "measure_type_6","active_carrier_6","central_freq_6","video_chan_6","audio_chan_6", #5
            ]
         },
         "TDMA"=> {
            :Format => "SCCC" + "CCC"+"sSsE"+"sssCCCC"+"SSsSS"+"CCCC"+"EEESS"+"CCee"+"SSSS",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2", #4
               'actual_mode','resv3','clear_acquisition_buffer', #3
               'external_temp','attenuator','internal_freq','centeral_freq', #4
               'channel','video_channel','audio_channel','trigger','trigger_slope','text_box_pos','mean_type', #7
               'avg_len','noise_marker','trigger_level','delay_after_trigger','delay_before_trigger',#5
               'clear_acquisition','horizontal_time','resolution_bw_auto_sel','video_bandwidth_auto_sel',#4
               'horizontal_time','resolution_bw','video_bw','vertical_scale','signal_bw_regarding_rbw', #5
               'vert_markers_disp','horz_markers_disp','first_vert_marker_pos','second_vert_marker_pos', #4
               'first_horz_marker_pos','second_horz_marker_pos','first_vert_marker_amp','second_vert_marker_amp' #4
            ]
         },
         "DM"=> {
            :Format => "SCCC" + "CSCCS"+"dSSSCC",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
            "actual_mode","resv3","freq_type","sec2_running","att_value",
            "freq","video_chan","audio_chan","vert_scale","field_nbr","line_nbr"]
         },
         "NI"=> {
            :Format => "SCCC" + "CSSdSS"+"CCCCll"+"llll"+"CCCC"+"lCCS",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
            "actual_mode","resv3","att_value","center_freq","video_chan","audio_chan",
            "avg_type","sub_mode","use_ps_filt","start_meas","CTN_inch_freq","CTN_bwd_corr",
            "cso_lf_off1","cso_lf_off2","cso_uf_off1","cso_uf_off2",
            "ctb_icf_off","resv4","field_nbr","line_nbr"]
         },
         "AUTO"=> {
            :Format => "SCCC" + "CCCSS",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
            "actual_mode","resv3","kind_of_measure","attenuator","active_channel_number"]
         },
         "MONITORING2"=> {
            :Format => "SCCC" + "C",
            :Keys => ["msghdr_len","subcommand",'resv1',"resv2",
            "actual_mode"]
         },
      }
      # ===@@setting_lookup
      # <b>Private Array</b>
      # Mode Number for settings.
      @@modes = ['SA','SS','BAS','DCP','SM',
                 'SM','SM6','SM6','HUM','NI', #SM6 for mode 7(autotest) is just filler. This wont work if we support autotest.
                 'FR','DM','RESV1','MONITORING','TDMA',
                 'QAM', 'MONITORING2','RESV2','DIGITAL MONITORING','ANALOG MONITORING']
      # ===@@general_commands
      # <b>Private HASH</b>
      # General Commands Hash( msg_type=20).
      @@general_commands={
         "1"=> {
            :FromClient =>
            {
               :Label  => 'Get Settings',
               :Keys            => ['len','subcommand','resv1'],
               :Format          => 'vCC',
               :Expected_Values => [0,1,nil]
            },
            :FromServer =>
            {
               :Label  => 'Get Settings',
               :ParseMsg=>lambda {|obj|
                  mode_nbr=obj.msg[5]
                  mode=@@modes[mode_nbr]
               return obj.unpack(@@setting_recs[mode])},
               :BuildMsg=>lambda {|obj|  return obj.pack(@@setting_recs[@@modes[obj[4].to_i]])},
               :Expected_Values => [0,1,nil]
            }
         },
         "2"=> {
            :FromClient =>
            {
               :Label  => 'Set Settings',
               :ParseMsg=>lambda {|obj|
                  mode_nbr=obj.msg[5]
                  mode=@@modes[mode_nbr]
               return obj.unpack(@@setting_recs[mode])},
               :BuildMsg=>lambda {|obj|  
                  return obj.pack(@@setting_recs[@@modes[obj.msg_obj["actual_mode"].to_i]])},
               :Expected_Values => [0,2,nil,nil]
            }
         },
         "3"=> {
            :FromClient =>
            {
               :Label  => 'Keep Alive',
               :Keys            => ['len','subcommand','resv1'],
               :Format          => 'vCC',
               :Expected_Values => [0,3,nil]
               #TODO - Depending on mode we get a lot of different stuff for the msg
            }
         },
         "4"=> {
            :FromClient =>
            {
               :Label  => 'Get Firmware Version',
               :Keys            => ['len','subcommand','resv1'],
               :Format          => 'vCC',
               :Expected_Values => [nil,4,nil]
            },
            :FromServer => {
               :Label  => 'Get Firmware Version',
               :Keys            => ['len','subcommand','resv1','hm_firmware_ver', 'spec_anz_ver',
                  'sys_sweep_ver','bidir_ver','dig_chan_pwr_ver','freq_cnt_ver',
                  'tv_chn_ver','multi_car_ver','auto_test_ver','hum_ver','disort_meas_ver',
                  'ifr_ver','dom_ver','tdma_ver','qam_ver','mon_ver','resv2',
                  'setup_ver','com_prot_ver','parameter_file_ver','switch_driver_ver','qam_diag_ver',
               'resv3','ostype','reservered4','minwinmon_ver'],
               :Format          => 'vCCa16vvvvvvvvvvvvvvva10vvvvva12CCV'

            }
         },
         "5"=> {
            :FromClient=>
            {
               :Label  => 'Get Date Time',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,5,nil]
            },
            :FromServer => {
               :Label  => 'Get Date Time',
               :Keys       => ['len','subcommand','resv1','year','month','day','hours','minutes','seconds','hunsecs'],
               :Format     => 'vCCvcccccc'
            }
         },
         "6"=> {
            :FromClient =>
            {
               :Label  => 'Set Date Time',
               :Keys       => ['len','subcommand','resv1','year','month','day','hours','minutes','seconds','hunsecs'],
               :Format     => 'vCCvcccccc',
               :Expected_Values => [nil,6,nil]
            }
         },
         "7"=> {
            :FromClient =>
            {
               :Label  => 'Get Hardware Configuration',
               :Keys       => ['len','subcommand','resv1'],
               :Format     => 'vCC',
               :Expected_Values => [4,7,nil]
            },
            :FromServer => {
               :Label  => 'Get Hardware Configuration',
               :Keys   => ['len','subcommand','resv1','system_type','system_sn','system_cal_date','m20_type','m20_sn',
                  'm20_cal_date', 'm13','m14','m15','m16','m17','m24','m25','m26','m27','m28','m29','m30','eth0',
               'ser','qam','arch','vid','batt','chg','max_freq','qam_mod','resv2'],
               :Format => 'vCCa20a20a20vva20a24a24a24a24a24a24a24a24a24a24a24a14a24a24a24a24CVa236',
               :Expected_Values => [376,7,nil,nil,nil]
            }
         },
         "8"=> {
            :FromClient =>
            {
               :Label  => 'Get Temperature',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,6,nil]
            },
            :FromServer => {
               :Label  => 'Get Temperature',
               :Keys       => ['len','subcommand','resv1','intern_temp','extern_temp'],
               :Format     => 'vCCvv',
               :Expected_Values => [nil,6,nil,nil,nil]
            }
         },
         "9"=> {
            :FromClient =>
            {
               :Label  => 'Init File Transfer',
               :Keys   => ['len','subcommand','resv1','upload','sug_proto','byte_len','block_size','resv2','fname_len','fname'],
               :Format => 'vCCCCVva8CZ*',
               :Expected_Values => [nil,9,nil]
            },
            :FromServer => {
               :Label  => 'Init File Transfer',
               :Keys       => ['len','subcommand','resv1','upload','proto','file_len','block_size','resv2'],
               :Format     => 'vCCCCVvC',
               :Expected_Values => [nil,9,nil,nil,nil]
            }
         },
         "10"=> {
            :FromClient =>
            {
               :Label  => 'File Transfer block',
               :Keys   => ['len','subcommand','resv1','seq','resv2','position','block_size','data'],
               :Format => 'vCCCCVva*'
            },
            :FromServer =>
            {
               :Label  => 'File Transfer block',
               :Keys   => ['len','subcommand','resv1','seq','resv2','position','block_size','data'],
               :Format => 'vCCCCVva*'
            }
         },
         "11"=> {
            :FromServer =>
            {
               :Label  => 'Close File Transfer ',
               :Keys   => ['len','subcommand','resv1','proto_ver','resv2','file_len','block_count','resv3'],
               :Format => 'vCCCCVva8',
               :Expected_Values => [nil,11,nil,nil,nil]
            },
            :FromClient =>
            {
               :Label  => 'Close File Transfer ',
               :Keys   => ['len','subcommand','resv1','proto_ver','resv2','file_len','block_count','resv3'],
               :Format => 'vCCCCVva8',
               :Expected_Values => [nil,11,nil,nil,nil]
            }
         },
         "12"=> {
            :FromClient =>
            {
               :Label  => 'Get Server Info',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
            },
            :FromServer => {
               :Label  => 'Get Server Info',
               :Keys       => ['len','subcommand','resv1','system_type','ver_and_comments'],
               :Format     => 'vCCa20a80',
               :Expected_Values => [nil,12,nil,nil,nil],
            }
         },
         "13"=> {
            :FromServer =>
            {
               :Label  => 'Synchronize',
               :Keys   => ['len','subcommand','resv1','bitmask','optional'],
               :Format => 'vCCSS'
            }
         },
         "14"=> {
            :FromServer =>
            {
               :Label  => 'Text Message',
               :Keys   => ['len','subcommand','resv1','option','message'],
               :Format => 'vCCna240'
            }
         },
         "15"=> {
            :FromClient =>
            {
               :Label  => 'Soft Reboot',
               :Keys   => ['len','subcommand','resv1','reboottype'],
               :Format => 'vCCv'
            }
         },
         "16"=> {
            :FromClient =>
            {
               :Label  => 'Get Connection Info',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,16,nil]
            },
            :FromServer => {
               :Label  => 'Get Connection Info',
               :ParseMsg => lambda { |obj|
                  msg_obj=Hash.new()
                  msg_obj['len_msg']=obj.msg[0] + obj.msg[1]*256
                  msg_obj['subcommand']=obj.msg[2] 
                  msg_obj['len_hm']=obj.msg[3]
                  curr_pos=4

                  tmp_len=msg_obj['len_hm'].to_i
                  msg_obj['hm']=obj.msg[curr_pos..curr_pos+tmp_len-1].unpack("A*")[0]
                  curr_pos=curr_pos+tmp_len

                  msg_obj['len_ip1']=obj.msg[curr_pos]
                  curr_pos=curr_pos+1
                  tmp_len=msg_obj['len_ip1'].to_i
                  msg_obj['ip1']=obj.msg[curr_pos..curr_pos+tmp_len-1].unpack("A*")[0]
                  curr_pos=curr_pos+tmp_len

                  msg_obj['len_ip2']=obj.msg[curr_pos]
                  curr_pos=curr_pos+1
                  tmp_len=msg_obj['len_ip2'].to_i
                  msg_obj['ip2']=obj.msg[curr_pos..curr_pos+tmp_len-1].unpack("A*")[0]
                  curr_pos=curr_pos+tmp_len

                  obj.msg_object=msg_obj
               }
            },
            :BuildMsg=>nil #TODO fix this
         },
         "17"=> {
            :FromClient =>
            {
               :Label  => 'Get Current Alarm Threshold',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,17,nil],
            },
            :FromServer => {
               :Label  => 'Get Current Alarm Threshold',
               :Keys   => ['len','subcommand','success','signal_count','resv1','alarm_thresh_id',
                  'thresh_alarm','compare_type',
                  'thresh_alarm','compare_type',
                  'thresh_alarm','compare_type',
                  'thresh_alarm','compare_type',
                  'thresh_alarm','compare_type',
                  'image'
               ],
               :Format => 'vCCvCC'+
               'vC' +
               'vC' +
               'vC' +
               'vC' +
               'vC' +
               'a625',
               :Expected_Values => [nil,17,nil]
            }
         },
         "18"=> {
            :FromClient =>
            {
               :Label  => 'Get File CRc32',
               :Keys   => ['len','subcommand','resv1','filename'],
               :Format => 'vCCZ*'
            },
            :FromServer => {
               :Label  => 'Get File CRc32',
               :Keys => ['len','subcommand','resv1','crc32','file_len'],
               :Format => 'vCCVV',
               :Expected_Values => [nil,18,nil]
            }

         },
         "19"=> {
            :FromClient =>
            {
               :Label  => 'Reload Channel Plan',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,19,nil],
            },
            :FromServer => {
               :Label  => 'Reload Channel Plan',
               :Keys => ['len','subcommand','resv1','crc32','file_len'],
               :Format => 'vCCVV',
               :Expected_Values => [nil,19,nil]
            }
         },
         "20"=> {
            :FromClient =>
            {
               :Label  => 'Get List of HM',
               :Keys   => ['len','subcommand','resv1'],
               :Format => 'vCC',
               :Expected_Values => [nil,20,nil],
            },
            :FromServer => {
               :Label  => 'Get List of HM',
               :ParseMsg => lambda { |obj|
                  msg_obj=Hash.new()
                  msg_obj['len_msg']=obj.msg[0] + obj.msg[1]*256
                  msg_obj['subcommand']=obj.msg[2] 
                  msg_obj['resv1']=obj.msg[3]
                  msg_obj['node_count']=obj.msg[4] + obj.msg[5]*256
                  msg_obj['node_list']=[]
		  node_idx=5
                  msg_obj['node_count'].times { |node_cnt|
		     node_idx+=1 
                     node_nbr=obj.msg[node_idx]
		     node_idx+=1 
                     node_avail=obj.msg[node_idx]
                     marker_idx=node_idx
		     node_idx+=1 
		     node_name=""
		     while obj.msg[node_idx] != 0 
			node_name << obj.msg[node_idx]
			node_idx+=1
		     end
                     node_idx=marker_idx+20
		     node={'node_nbr'=>node_nbr,'node_name'=>node_name, 'node_avail' => node_avail}
                     msg_obj['node_list'].push(node)
                  }
                  obj.msg_object=msg_obj
               },
               :BuildMsg=>nil #TODO fix this
            }
         },
         "21"=> {
            :FromClient =>
            {
               :Label  => 'Get List of Node Names',
               :Keys   => ['len','subcommand','resv1','first_pos','alpha'],
               :Format => 'vCCsC',
               :Expected_Values => [nil,21,nil]
            },
            :FromServer => {
               :Label  => 'Get List of Node Names',
               :ParseMsg => lambda { |obj|
                  msg_obj=Hash.new()
                  msg_obj['len_msg']=obj.msg[0] + obj.msg[1]*256
                  msg_obj['subcommand']=obj.msg[2] 
                  msg_obj['resv1']=obj.msg[3]
                  msg_obj['first_node_pos']=obj.msg[4] + obj.msg[5]*256
                  msg_obj['alpha']=obj.msg[6]
                  msg_obj['node_count']=obj.msg[7] + obj.msg[8]*256
                  msg_obj['node_list']=[]
                  node_idx=9
                  msg_obj['node_count'].times { |node_cnt|
                     node_nbr=obj.msg[node_idx]+obj.msg[node_idx + 1]*256
                     node_idx+=2
                     node_name=""
                     while obj.msg[node_idx] != 0
                        node_name<<obj.msg[node_idx]
                        node_idx+=1
                     end
                     node_idx+=1
		     node={'node_nbr'=>node_nbr,'node_name'=>node_name}
                     msg_obj['node_list'].push(node)
                  }
                  obj.msg_object=msg_obj
               },
               :BuildMsg=>nil #TODO fix this
            }
         },
         "22"=> {
            :FromClient =>
            {
               :Label  => 'Rename File',
               :Keys   => ['len','subcommand','resv1','src_fn','dest_fn'],
               :Format => 'vCCZ*Z*',
               :Expected_Values => [nil,22,nil]
            }
         },
         "23"=> {
            :FromClient =>
            {
               :Label  => 'Delete Files',
               :ParseMsg=>nil, #TODO fix this
               :BuildMsg=>nil #TODO fix this
            }
         },
         "25"=> {
            :FromClient =>
            {
               :Label  => 'Transaction Request',
               :Keys   => ['len','subcommand','resv1','transaction_type','resource_idx'],
               :Format => 'vCCCv',
               :Expected_Values => [nil,25,nil]
            }
         },
         "26"=> {
            :FromClient =>
            {
               :Label  => 'SNMP Config',
               :Keys   => ['len','subcommand','resv1','snmp_ver','user','trap_port',
               'community','nb_clients','ip1','ip2','ip3','ip4','ip5'],
               :Format => 'vCCa41sa80Ca16a16a16a16a16',
               :Expected_Values => [nil,26,nil]
            }
         }
      }

      # ===@@switch_commands
      # <b>Private HASH</b>
      # Switch Commands Hash( msg_type=80).
      @@switch_commands =
      {
         'ELSE' => { #All other values
            :FromClient =>
            {
               :Label => 'Select RPTP Number',
               :Keys => ['len_msg','rptp_number'],
               :Format =>  'SS'
            }
         },
         '32769' => { #0x8001
            :FromClient =>
            {
               :Label => 'Ask for current RPTP number',
               :Keys => ['len_msg','subcommand'],
               :Format =>  'SS'
            },
            :FromServer => {
               :Label => 'Ask for current RPTP number response',
               :Keys => ['len_msg','subcommand','actual_rptp_nbr'],
               :Format =>  'SSS'
            }
         },
         '32770' => { #0x8002
            :FromClient =>
            {
               :Label => 'Ask for Number of RPTP',
               :Keys => ['len_msg','subcommand'],
               :Format =>  'SS'
            },
            :FromServer => {
               :Label => 'Ask for Number of RPTP response',
               :Keys => ['len_msg','subcommand','rptp count'],
               :Format =>  'SSS'
            }
         },
         '32772' => { #0x8004
            :FromClient =>
            {
               :Label => 'Clear RPTP',
               :Keys => ['len_msg','subcommand','rptp_to_clear'],
               :Format =>  'SSS'
            }
         },
         '32773' => { #0x8005
            :FromClient =>
            {
               :Label => 'Clear RPTP',
               :Keys => ['len_msg','subcommand','rptp_to_select'],
               :Format =>  'SSS'
            }
         },
         '32774' => { #0x8006
            :FromClient =>
            {
               :Label => 'Toggle an RPTP RPTP',
               :Keys => ['len_msg','subcommand','rptp_to_select'],
               :Format =>  'SSS'
            }
         },
         '32775' => { #0x8007
            :FromClient =>
            {
               :Label => 'Add an RPTP to current selection',
               :Keys => ['len_msg','subcommand','rptp_to_select'],
               :Format =>  'SSS'
            }
         },
         '32776' => { #0x8008
            :FromClient =>
            {
               :Label => 'Ask for the list of selected RPTP',
               :Keys => ['len_msg','subcommand'],
               :Format =>  'SS'
            },
            :FromServer =>
            {
               :Label => 'Ask for the list of selected RPTP response',
               :ParseMsg => lambda { |obj|
                  msg_obj=Hash.new()
                  msg_obj['len_msg']=obj.msg[0] + obj.msg[1]*256
                  msg_obj['subcommand']=obj.msg[2] + obj.msg[3]*256
                  rptp_count=obj.msg[4] + obj.msg[5]*256
                  msg_obj['rptp_count']=rptp_count
                  msg_obj['rptp_list']=Array.new()
                  rptp_count.times { |index|

                     rptp=obj.msg[index*2+6]+obj.msg[index*2+7]*256
                     msg_obj['rptp_list'].push(rptp)
                  }
                  obj.msg_object=msg_obj
               },
               :BuildMsg => lambda { |obj|
                  #TODO finish this.
               }
            }
         },
         '32777' => { #0x8009
            :FromClient =>
            {
               :Label => 'Ask for the list of available RPTP',
               :Keys => ['len_msg','subcommand'],
               :Format =>  'SS'
            },
            :FromServer =>
            {
               :Label => 'Ask for the list of available RPTP',
               :ParseMsg => lambda { |obj|
                  msg_obj=Hash.new()
                  msg_obj['len_msg']=obj.msg[0] + obj.msg[1]*256
                  msg_obj['subcommand']=obj.msg[2] + obj.msg[3]*256
                  rptp_count=obj.msg[4] + obj.msg[5]*256
                  msg_obj['rptp_count']=rptp_count
                  msg_obj['rptp_list']=Array.new()
                  rptp_count.times { |index|

                     rptp=obj.msg[index*2+6]+obj.msg[index*2+7]*256
                     msg_obj['rptp_list'].push(rptp)
                  }
                  obj.msg_object=msg_obj
               },
               :BuildMsg => lambda { |obj|
                  #TODO finish this.
               }
            }
         },
         '32778' => { #0x800A
            :FromClient =>
            {
               :Label => 'Allow sequence mode',
               :Keys => ['len_msg','subcommand','sequence_mode_value'],
               :Format =>  'SSS'
            }
         },
         '32784' => { #0x8010
            :FromClient =>
            {
               :Label => 'Update SUNRISE Switch firmware',
               :Keys => ['len_msg','subcommand'],
               :Format =>  'SS'
            }
         }
      }
      # ===@@crc_table
      # <b>Private ARRAY</b>
      # This array is used to simplify the CRC calculations...
      @@crc_table =
      [
         0x0000,  0x1021,  0x2042,  0x3063,  0x4084,  0x50A5,  0x60C6,  0x70E7,
         0x8108,  0x9129,  0xA14A,  0xB16B,  0xC18C,  0xD1AD,  0xE1CE,  0xF1EF,
         0x1231,  0x0210,  0x3273,  0x2252,  0x52B5,  0x4294,  0x72F7,  0x62D6,
         0x9339,  0x8318,  0xB37B,  0xA35A,  0xD3BD,  0xC39C,  0xF3FF,  0xE3DE,
         0x2462,  0x3443,  0x420,   0x1401,  0x64E6,  0x74C7,  0x44A4,  0x5485,
         0xA56A,  0xB54B,  0x8528,  0x9509,  0xE5EE,  0xF5CF,  0xC5AC,  0xD58D,
         0x3653,  0x2672,  0x1611,  0x0630,  0x76D7,  0x66F6,  0x5695,  0x46B4,
         0xB75B,  0xA77A,  0x9719,  0x8738,  0xF7DF,  0xE7FE,  0xD79D,  0xC7BC,
         0x48C4,  0x58E5,  0x6886,  0x78A7,  0x0840,  0x1861,  0x2802,  0x3823,
         0xC9CC,  0xD9ED,  0xE98E,  0xF9AF,  0x8948,  0x9969,  0xA90A,  0xB92B,
         0x5AF5,  0x4AD4,  0x7AB7,  0x6A96,  0x1A71,  0x0A50,  0x3A33,  0x2A12,
         0xDBFD,  0xCBDC,  0xFBBF,  0xEB9E,  0x9B79,  0x8B58,  0xBB3B,  0xAB1A,
         0x6CA6,  0x7C87,  0x4CE4,  0x5CC5,  0x2C22,  0x3C03,  0x0C60,  0x1C41,
         0xEDAE,  0xFD8F,  0xCDEC,  0xDDCD,  0xAD2A,  0xBD0B,  0x8D68,  0x9D49,
         0x7E97,  0x6EB6,  0x5ED5,  0x4EF4,  0x3E13,  0x2E32,  0x1E51,  0x0E70,
         0xFF9F,  0xEFBE,  0xDFDD,  0xCFFC,  0xBF1B,  0xAF3A,  0x9F59,  0x8F78,
         0x9188,  0x81A9,  0xB1CA,  0xA1EB,  0xD10C,  0xC12D,  0xF14E,  0xE16F,
         0x1080,  0x00A1,  0x30C2,  0x20E3,  0x5004,  0x4025,  0x7046,  0x6067,
         0x83B9,  0x9398,  0xA3FB,  0xB3DA,  0xC33D,  0xD31C,  0xE37F,  0xF35E,
         0x02B1,  0x1290,  0x22F3,  0x32D2,  0x4235,  0x5214,  0x6277,  0x7256,
         0xB5EA,  0xA5CB,  0x95A8,  0x8589,  0xF56E,  0xE54F,  0xD52C,  0xC50D,
         0x34E2,  0x24C3,  0x14A0,  0x0481,  0x7466,  0x6447,  0x5424,  0x4405,
         0xA7DB,  0xB7FA,  0x8799,  0x97B8,  0xE75F,  0xF77E,  0xC71D,  0xD73C,
         0x26D3,  0x36F2,  0x0691,  0x16B0,  0x6657,  0x7676,  0x4615,  0x5634,
         0xD94C,  0xC96D,  0xF90E,  0xE92F,  0x99C8,  0x89E9,  0xB98A,  0xA9AB,
         0x5844,  0x4865,  0x7806,  0x6827,  0x18C0,  0x08E1,  0x3882,  0x28A3,
         0xCB7D,  0xDB5C,  0xEB3F,  0xFB1E,  0x8BF9,  0x9BD8,  0xABBB,  0xBB9A,
         0x4A75,  0x5A54,  0x6A37,  0x7A16,  0x0AF1,  0x1AD0,  0x2AB3,  0x3A92,
         0xFD2E,  0xED0F,  0xDD6C,  0xCD4D,  0xBDAA,  0xAD8B,  0x9DE8,  0x8DC9,
         0x7C26,  0x6C07,  0x5C64,  0x4C45,  0x3CA2,  0x2C83,  0x1CE0,  0x0CC1,
         0xEF1F,  0xFF3E,  0xCF5D,  0xDF7C,  0xAF9B,  0xBFBA,  0x8FD9,  0x9FF8,
         0x6E17,  0x7E36,  0x4E55,  0x5E74,  0x2E93,  0x3EB2,  0x0ED1,  0x1EF0
      ]
      # This is the number of bytes in the header
      HEADER_LENGTH = 15

      AND_SHORT=65535
      @@header_format="aaa2a2a2a3a1a3"


      #This is the number to add when switching from Hexa to Ascii
      ASCII_OFFSET = 0x30

      #This is the number to add when switching a hex letter( A to F )
      #from Hexa to Ascii
      HEX_LETTER_OFFSET = 0x41

      #This is the number of bytes in the footer.
      FOOTER_LENGTH = 4

      #This is the position of the SOURCE_ID field in the header
      SOURCE_ID_POSITION= 2

      #This is the position of the SOURCE_ID field in the header
      DESTINATION_ID_POSITION= 4


      #This is the position of the SEQUENCE field in the header
      SEQUENCE_POSITION= 11
      #This is the position of the SEQUENCE field in the header for 1800 and
      #3000 messages.
      NEW_SEQUENCE_POSITION = 10


      #This is the position of the TYPE field in the header
      TYPE_POSITION= 6

      #This is the position of the SUBTYPE field in the header
      SUBTYPE_POSITION= 8

      #This is the position of the DATA LENGTH field in the header
      DATA_LENGTH_POSITION= 12

      #This is the position of the DATA field in the header
      DATA_POSITION= HEADER_LENGTH


      #This is the first byte of a message
      HD1 = 0x01


      #This is the second byte of a message
      HD2 = 0x02

      # ===ParsePacket
      # <b>Class Function</b>
      # Given a packet it generate the corresponding AvantronRec
      def AvantronRec.parsePacket(avantron_packet,from_analyzer,logger)
         if (avantron_packet.nil? || (avantron_packet.length < 2) ||  (avantron_packet[0] != 1) || (avantron_packet[1]!=2))
            logger.debug "Ignoring Gibberish #{avantron_packet.inspect}"
            #raise ProtocolError.new("Bad packet | #{avantron_packet.inspect}")
            return nil
         end
         packet_buffer_pos=2
         header_arr=avantron_packet[0..HEADER_LENGTH].unpack(@@header_format)
         packet_buffer_pos=HEADER_LENGTH
         av=AvantronRec.new(header_arr[2], header_arr[3], header_arr[4],header_arr[5],logger, header_arr[6].to_i,header_arr[7].to_i, from_analyzer)
         av.msg=avantron_packet[packet_buffer_pos,av.msg_len]
         packet_buffer_pos+=av.msg_len
         if packet_buffer_pos > avantron_packet.length
             raise ProtocolError.new("Positions wrong for CRC.Position => #{packet_buffer_pos},msg len => #{av.msg_len},avantron_packet length => #{avantron_packet.length}")
         end
         crcpacked=avantron_packet[packet_buffer_pos,2]
         crc_size=DATA_POSITION+av.msg_len.to_i
         accum=AvantronRec.calcCrc(crc_size,avantron_packet[0..crc_size])
         if crcpacked.nil?
             raise ProtocolError.new("CRC Packet is wrong ")
         end
         crc=crcpacked.unpack("n")
         packet_buffer_pos+=2

         tail_end=['z','y']
         tail_end[0]=avantron_packet[packet_buffer_pos]
         packet_buffer_pos+=1
         tail_end[1]=avantron_packet[packet_buffer_pos]
         packet_buffer_pos+=1
         if (tail_end[0].to_i==3 && tail_end[1].to_i==4)
         else
            logger.debug "Socket failed End: #{crc} , #{tail_end[0].to_i},#{tail_end[1].to_i} "
            cnt=0
            #   while(x=socket.getc)
            #   print("#{cnt}->#{x},")
            #   cnt+=1
            #end

         end
         av.msg_obj()
         #logger.debug ">----------PARSED #{av.inspect()} ,"
         #logger.debug "<---------------"
         #logger.debug " "
         return av
      end

      # ===buildPacket
      # <b>Public Function</b>
      # Generates the packet string for the AvantronRec 
      def buildPacket(msg_object=nil)
         packet=String.new()
         packet << 1
         packet << 2
         packet << @source
         packet << @destination
         packet << @msg_type
         packet << @node_nbr
         packet << sprintf("%d",@packet_seq)
         #TODO . should build msg_str from msg_object
         if (msg_object != nil)
            if !msg_object.is_a? Hash
               raise ProtocolError.new("Message Object must be a hash")
            else
               @msg_object=msg_object
            end
         end
         @msg_len= sprintf("%03d",msg_str().length)
         packet << @msg_len
         packet << msg_str()
         crc_size=DATA_POSITION+@msg_len.to_i
         if (packet.length()!= crc_size)
            @logger.debug "#{packet.length} <> #{crc_size}"
            @logger.debug "----#{packet.class}"
            packet.each_byte {|c|
                  @logger.debug "#{c},"
            }
            @logger.debug "----"
            @logger.debug packet.inspect()
            raise ProtocolError.new("#{packet.length} <> #{crc_size}")
         end
         accum=AvantronRec.calcCrc(crc_size,packet)
         packet << [accum].pack("n")
         packet << 3
         packet << 4
         return packet
      end

      # ===initialize
      # <b>Public Function</b>
      # Constructor
      def initialize(source, destination, msg_type, node_nbr,logger=nil,
         packet_seq='0', msg_len=nil, from_analyzer=false)
         if logger==nil
            @logger=Logger.new($stderr)
         else
            @logger=logger
         end
         @source=sprintf("%02d",source.to_i)
         if (destination.nil?)
            @destination="~~"
         else
            @destination=sprintf("%02d",destination.to_i)
         end
         @msg_type=sprintf("%02d",msg_type.to_i)
         @node_nbr=sprintf("%03d",node_nbr.to_i)
         if (node_nbr.nil?)
            @node_nbr="~~"
         else
            @node_nbr=sprintf("%03d",node_nbr.to_i)
         end
         #@packet_seq=packet_seq
         @packet_seq=9
         @msg_len=msg_len
         @msg=nil
         @msg_object=nil
         @packet_buffer
         if (from_analyzer.nil?)
            @from_analyzer=(@source.to_i > 9)
         else
            @from_analyzer=from_analyzer
         end
      end
      # ===inspect
      # <b>Public Function</b>
      # Inspection function for debugging.
      def inspect()
         inspected_obj=''
         inspected_obj << "From Analyzer #{@from_analyzer} \n"
         inspected_obj << "SOURCE: #{@source} |"
         inspected_obj << "DESTINATION: #{@destination} |"
         inspected_obj << "MSG TYPE: [ #{@msg_type} ] #{msg_label()} |"
         inspected_obj << "NODE NBR: #{@node_nbr} |"
         inspected_obj << "PACKET SEQ: #{@packet_seq} |"
         inspected_obj << "MSG LEN: #{@msg_len} |\n"
         inspected_obj << "MSG OBJ: #{self.msg_object.inspect()}"
         return inspected_obj
      end
      # ===calcCrc
      # <b>Class Function</b>
      # This function calculates the CRC for the message and returns it
      # Returns The calculated CRC.
      def AvantronRec.calcCrc(packet_len,packet_buffer)
         i=0
         accum = 0
         len = packet_len

         len.times {|i|
            crc_index= ((accum >> 8) ^ packet_buffer[i])

            tabvalue = @@crc_table[crc_index]
            accum = ((accum << 8) ^ (tabvalue)) & AND_SHORT
         }
         return (accum)

      end

   end
end
