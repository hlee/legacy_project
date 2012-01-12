#!/usr/bin/env ruby

require 'socket'
require 'webrick/httprequest'
require 'webrick/httpresponse'
require 'webrick/config'

include Avantron
include Socket::Constants


class InstrumentSession
   attr_reader :ip,:port,:rw_addr,:analyzer_addr,:dl_process,:command_io
   attr_writer :socket,  :command_io, :todo_list, :dl_process, :logger,:command_process
   attr_accessor :dir_prefix,:nack_error
   NoChange=0
   Stop=1
   Ingress=2
   QamQuery=3
   AnalogQuery=4
   def initialize(ip,port,rw_addr, logger=nil,analyzer_addr='01', analyzer_id=nil)
      @analyzer_addr=analyzer_addr
      @ip=ip
      @port=port
      @rw_addr=rw_addr
      @socket=nil
      @command_io=nil
      @todo_list=[]
      @dl_process=nil
      @command_process=nil
      @analyzer_id=analyzer_id
      @dir_prefix='/tmp'
      if logger==nil
         @logger.debug "Setting logger=nil"
         #@logger=Logger.new($stderr)
         @logger=nil
      else
         logger.debug "Initialize Instrument Session INSTRUMENT HMID= #{@analyzer_addr}"
         @logger=logger
      end
   end

   def set_hmid(analyzer_addr)
      @analyzer_addr=analyzer_addr
   end


   def read_response(timeout=10)
      packet_found=0
      input_list=[]
      input_list.push(@socket)
      if (!@command_io.nil?())
         input_list.push(@command_io)
      end
      while (packet_found == 0)
         result=select(input_list,nil,nil,timeout)
         if result.nil?
            return nil
         end
         result[0].each { |input|
            if (input == @command_io)
               #@logger.debug "Tommie, we got a command"
               if (!@command_process.nil?)
                  @command_process.call(input)
               end
            elsif (input==@socket)
               buffer=''
               a_byte= input.read(1)
               if a_byte.nil?
                  @logger.debug("Why is the first byte nil?")
                  @logger.error("Why is the first byte nil? ")
                  return nil
               end
               buffer << a_byte
               if (buffer.length == 1) && (buffer[0]==1)
                  # First Character correct
                  buffer << input.read(1)
                  if (buffer.length == 2) && (buffer[1]==2)
                     # Second Character correct
                     buffer << input.read(13)
                     if (buffer.length == 15)
                        len=buffer[12,3].to_i
                        buffer << input.read(len+4)
                        if (buffer.length==(15+len+4)) && (buffer[-2] == 3) && (buffer[-1]== 4)
                           return buffer
                        end
                     end

                  end
               end
            else
               raise(ProtocolError.new("Packet format does not Avantron protocol."))

            end
         }
      end
      @logger.debug("Got Nothing from Select")
      return nil
   end
   def ack_async
      avantronrec=Avantron::AvantronRec.new(@rw_addr,@analyzer_addr,'1','001',@logger,1)
      packet=avantronrec.buildPacket({'retcode'=>0})
      @socket.write(packet)
   end
   def check_async_messages(avantron_rec)
      if ((avantron_rec.msg_type.to_i == 20) && avantron_rec.msg_object.key?('subcommand') &&
         (avantron_rec.msg_object['subcommand'].to_i == 13))
         ack_async()
         return true
      else
         return false
      end
   end
   def parse_response(timeout=10, expected_msg_type=nil)
      count =0
      response=nil
      while (response.nil? && count <= 6)
         response_packet=read_response(timeout)
         response=AvantronRec.parsePacket(response_packet,true,@logger)
         count+=1
         if (!expected_msg_type.nil? && !response.nil? && response.msg_type.to_i != expected_msg_type)
            response=nil
         end
      end
      return response
   end
   def do_todo
      while (item=@todo_list.pop())
         if (item == 'datalogging')
            self.datalogging_transaction()
         else
            raise(ProtocolError.new('Unrecognized todo #{item}'))
         end
      end
   end
   def handle_async_messages(avantron_rec)
      if (avantron_rec.msg_object['bitmask']==16384)
         #@todo_list.push('datalogging')
         #self.datalogging_transaction() Instead of handling datalogging here. Let's just call the dl_process flag.
         if !self.dl_process.nil?
            @logger.debug "ANALYZER_ID=#{@analyzer_id}"
            dl_process.call(@analyzer_id)
         else
            @logger.debug('Async message is not handled')
            #raise('Async message is not handled')
         end


      end
      return true
   end
   def msg_with_ack(msg_type, node_nbr, msg_obj,packet_seq=1, retry_count=3)
      @nack_error=nil
      if @socket.nil?
         raise(ProtocolError.new("Socket has not been set"))
      end
      #Clear Out Asynchronous Packets first.
      @logger.debug("Clear Out Asynchronous Packets First")
      async_packet=read_response(0)
      if (!async_packet.nil?)
         async_rec=AvantronRec.parsePacket(async_packet,true,@logger)
         if (check_async_messages(async_rec))
            handle_async_messages(async_rec)
         end
         #async_packet=read_response()
      end
      got_response=false
      try_count=0
      while(!got_response && (try_count <= retry_count))
         @logger.debug("Attenmpt to send Message Type: #{msg_type}, Trail # #{try_count}")
         #if try_count==1
         #   raise("Multiple attempts, please die"
         #end
         try_count+=1
         avatronrec=Avantron::AvantronRec.new(@rw_addr,@analyzer_addr,msg_type,node_nbr,@logger,packet_seq)
         packet=avatronrec.buildPacket(msg_obj) #{'resv1'=>0}
         if try_count > 1
            async_packet=read_response(0)
            while (!async_packet.nil?)
               @logger.debug "Parsing Asynchronous packet"
               async_rec=AvantronRec.parsePacket(async_packet,true,@logger)
               if (check_async_messages(async_rec))
                  handle_async_messages(async_rec)
               end
               async_packet=read_response(0)
            end
         end
         begin
         count=@socket.write(packet)
         rescue Errno::EPIPE =>e
            raise SunriseError.new(e.message)
         end
         if (count != packet.size)
            raise(ProtocolError.new("Was not able to send Command #{msg_type}"))
         end
         while(response_packet=read_response(20))
            response=AvantronRec.parsePacket(response_packet,true,@logger)
            error_list={0=>'FULL_PIPE',1=>'BUSY_SYST',2=>'NO LOGON',3=>'NO_SAME_MODE',
               4=>'NO_MASTER', 5=>'WAIT_RX_SETTING',6=>'ID_ALREADY_LOGON', 7=>'COMMAND_NOT_VALID',
               8=>'COMMAND_ALREADY_EXECUTED', 9=>'MODE_ALREADY_EXECUTED',10=>'MULTI_USER_SAME_MODE',11=>'COPYING_DATA',
               12=>'XFER_PAQUET_ERROR',13=>'XFER_DO_CANCEL',14=>'NACK_TRANSFERRING_FILE',15=>'NACK_INVALID_FILE_NAME',
            16=>'NACK_ERROR_PROCESSING_CMD', 17=>'NACK_MONITORING_RUNNING', 99=>'FUTURE OPTION'}
            if (response.msg_type == '01')
               got_response=true
               return 1
            elsif (response.msg_type.to_i == 2)
               error=error_list[response.msg_obj['errorcode']]
               @logger.debug("I received a NACK with Error Code: #{error} ")
               @logger.debug(response.inspect())
               @nack_error=error
               got_response=true
               return 0
            elsif check_async_messages(response)
               handle_async_messages(response)
            else
               @logger.debug('I Received a message I did not want')
               @logger.debug(response.inspect())
               return -1
            end
            @logger.debug("msg Ack failed for msg #{msg_type}... try count is #{try_count}")
         end
      end
      @nack_error="Analyzer not responding."
      if !avatronrec.nil?
        @nack_error = " Analyzer not responding #{avatronrec.msg_label} failed."
      end
      @logger.debug("msg Ack failed for msg #{msg_type}")
      return 0
   end
   def initialize_socket(clear_buffer=true)
      try_count=0
      #Build Instrument Socket
      @logger.debug("Opening socket to #{port.to_i} at ip #{ip.to_s}")
      begin
         @socket=nil
         timeout(3) do
            try_count += 1
              @socket=TCPSocket::new(ip.to_s,port.to_i)
         end
      rescue TimeoutError
         @logger.debug "Failed to connect to socket on attempt #{try_count}"
         if (try_count < 3)
           retry
         else
           raise SunriseError.new("Failed to connect to socket of #{ip.to_s}")
         end
      rescue Errno::EINPROGRESS
         IO.select(nil,[@socket])
         begin
            @socket.connect_nonblock(sockaddr)
            rescue Errno::EISCONN
         end

      end
      @logger.debug("successful socket to #{port.to_i} at ip #{ip.to_s}")
      #I'm guessing that this is some sort of buffer clearing.
      if @socket.nil?
         raise(ProtocolError.new("Failed to connect to #{ip.to_s} on port #{port.to_i}"))
      end
      if (clear_buffer)
         @socket.write([24,24,24,24,24,24,24,24,24,24,24].pack('C11'))
         @socket.write('\n')
      end
      @logger.debug("Doing a select to clear out messages #{port.to_i} at ip #{ip.to_s}")
      clear_count=0
      while(select([@socket],nil,nil,4)!=nil)
         msg, from =@socket.recvfrom(1000,0)
         clear_count +=1
         @logger.debug("While Clearing  we got #{msg}")
         if (clear_count >= 40) 
           raise(SunriseError.new("Failed to Clear Socket. Try Reconnecting.")) 
         end
      end
      @logger.debug("We got #{msg}")
   end

   def reboot()
      raise(ProtocolError.new("Failed to Reboot")) if (self.msg_with_ack('20','001',{'subcommand'=>15,'reboottype'=>170,'resv1'=>0,'len'=>0,},1)!=1)
      @logger.debug "Reboot Analyzer"
   end

   def upload_file(srcfile,destfile, &status_block)
      raise(ProtocolError.new("#{srcfile} does not exist.")) if !File.file?(srcfile)
      raise(ProtocolError.new("#{srcfile} does not exist.")) if !File.readable?(srcfile)
      file_length=File.size(srcfile)
      raise(ProtocolError.new("Failed to Init Transfer")) if (self.msg_with_ack('20','001',{'subcommand'=>9,'len'=>0,'resv1'=>0,'upload'=>1,
      'sug_proto'=>1,'byte_len'=>file_length,'block_size'=>950,'resv2'=>"\0",'fname_len'=>destfile.length,'fname'=>destfile},1)!=1)
      @logger.debug "Uploading #{srcfile} to #{destfile}"
      # Response for init file transfer.
      response=parse_response()
      block_size=response.msg_obj()['block_size']
      raise(ProtocolError.new('Failure to Transfer file.  Block size is zero')) if (block_size == 0)
      #--------------------------
      # Response for first set of bytes.
      block_count=0
      byte_count=0
      open(srcfile, 'r') { |f|
         while (content=f.read(block_size))
            if !status_block.nil?
               status_block.call(byte_count,file_length)
            end
            @logger.debug("Read file packet")
            raise(ProtocolError.new("Failed to send content")) if (self.msg_with_ack('20','001',{'len'=>0,'subcommand'=>10,'resv1'=>0,
            'seq'=>block_count, 'resv2'=>0,'position'=>block_count,'block_size'=>content.length,'data'=>content},1)!=1)
            byte_count = byte_count + content.length
            block_count= block_count +1
            @logger.debug "Block Count #{block_count}"
         end
      }
      close_file=parse_response()

      ack=AvantronRec.new(close_file.destination, close_file.source, 1, '001',@logger,'0')
      ack_packet=ack.buildPacket({'retcode'=>0})
      @socket.write(ack_packet)
      return true
      #--------------
      #   raise(("Failed to Logout to instrument")) if (self.msg_with_ack('04','001',{'resv1'=>0},1)!=1)
   end

   def datalogging_transaction()
      # Start transaction
      raise(ProtocolError.new("Failed Transaction")) if (self.msg_with_ack('20','001',
      {'subcommand'=>25,'len'=>0,'resource_idx'=>16384,
      'transaction_type'=>1,'resv1'=>0,"len"=>0})!=1)

      begin
        self.download_file('data.logging.buffer')
      rescue
        @logger.debug "REDO TRANSACTION"
        self.download_file('data.logging.buffer')#Retry the datalog download
      end


      # Stop transaction
      raise(ProtocolError.new("Failed Transaction")) if (self.msg_with_ack('20','001',
      {'subcommand'=>25,'len'=>0,'resource_idx'=>16384,
      'transaction_type'=>2,'resv1'=>0,"len"=>0})!=1)
   end

   def download_file(file, dir_prefix=nil)
      if (dir_prefix.nil?)
         dir_prefix=@dir_prefix
      end
      if ((dir_prefix[dir_prefix.length-1]!='/'))
         dir_prefix=dir_prefix << '/'
      end
      write_fname="#{dir_prefix}#{File.basename(file)}"
      raise(ProtocolError.new("Failed to Init Transfer")) if (self.msg_with_ack('20','001',{'subcommand'=>9,'len'=>0,'resv1'=>0,'upload'=>0,
      'sug_proto'=>1,'byte_len'=>0,'block_size'=>950,'resv2'=>"\0",'fname_len'=>11,'fname'=>(file<<0)},1)!=1)
      @logger.debug "Downloading #{file}"
      # Response for init file transfer.
      response=parse_response()
      #--------------------------
      # Response for first set of bytes.
      file_length=response.msg_object()['file_len'].to_i
      block_count=0
      byte_count=0
      out=open(write_fname, 'w')
      @logger.debug  "#{byte_count} / #{file_length}"
      until byte_count >= file_length
         fileblock_obj=parse_response()
         ack=AvantronRec.new(fileblock_obj.destination, fileblock_obj.source, 1, '001',@logger,fileblock_obj.packet_seq)
         ack_packet=ack.buildPacket({'retcode'=>fileblock_obj.msg_object()['seq']})
         @socket.write(ack_packet)
         byte_count = byte_count + fileblock_obj.msg_object()['block_size']
         block_count= block_count +1
         #@logger.debug "Blocks; Byte Count:#{byte_count} Block Count:#{block_count}"
         out << fileblock_obj.msg_object()['data']
      end
      out.close
      raise(ProtocolError.new("Failed to Close file")) if (self.msg_with_ack('20','001',
      {'len'=>0,'subcommand'=>11,'resv1'=>0,'proto_ver'=>1,'resv2'=>0,'file_len'=>byte_count,
      'block_count'=>block_count,'resv3'=>''},1)!=1)
      #--------------
      #   raise(ProtocolError.new  ("Failed to Logout to instrument")) if (self.msg_with_ack('04','001',{'resv1'=>0},1)!=1)
   end
   def diagnostic(timeout=6)
      raise(ProtocolError.new("Failed to Start_diagnostic")) if (self.msg_with_ack('7','001',
         { :hdr_len=>29, :subcommand=>3, :resv=>0,:power_flag=>1,:mer_flag=>1, :enm_flag=>1, :evm_flag=>1, :sys_noise_flag=>1, :cw_infc_flag=>1, :freq_resp_flag=>1, 
            :margin_flag=>1, :margin_tap_flag=>1, :compression_flag=>1, :digital_hum_flag=>1, :phase_noise_flag=>1, :IQ_gain_diff_flag=>1, :iq_phase_diff_flag=>1, 
            :carrier_flag=>0, :symbol_rate_flag=>0,:resv2=>''},2)!= 1)
      giveup=Time.now()+60
        diagnostic_response=nil
      while diagnostic_response.nil? && (Time.now() < giveup)
         @logger.debug "=Check for Diagnostic Response #{Time.now()}, #{giveup}"
         #diagnostic_response=parse_response(timeout)
         #diagnostic_response=trigger(1)
      raise(ProtocolError.new("Failed to Trigger")) if (self.msg_with_ack('98','001',
         {'trace_count_to_perform'=>1,'acquisition_buffer_reset'=>1},2)!= 1)
      trigger_response=parse_response()
         @logger.debug trigger_response.inspect()
      end
      if diagnostic_response.nil?
         @logger.debug "=DIAGNOSTIC We got Nothing Nothing!!!"
      else
         @logger.debug "=DIAGNOSTIC We Got #{diagnostic_response}"
      end
      return diagnostic_response
   end

   def trigger(acquisition_count=1)
      #'98'=> { :TypeLabel=>'TRIGGER', :Format=>'CC',:Keys=>['trace_count_to_perform','acquisition_buffer_reset']},
      raise(ProtocolError.new("Failed to Trigger")) if (self.msg_with_ack('98','001',
         {'trace_count_to_perform'=>acquisition_count.to_i,'acquisition_buffer_reset'=>1},2)!= 1)
      trigger_response=parse_response()
      return trigger_response
   end

   def get_rptp_count
      raise(ProtocolError.new("Failed to get RPTP count")) if (self.msg_with_ack('80','001',{'len_msg'=>0,'subcommand'=>32770},2)!= 1)
      rptp_count_object=parse_response()
      if !rptp_count_object.msg_object().key?('rptp count')
         raise(ProtocolError.new("RPTP Count field does not exist"))
      end
      return rptp_count_object.msg_object()['rptp count']
   end

   def get_rptp_list(available=true)
      if (available)
         raise(ProtocolError.new("Failed to Get available port list")) if (self.msg_with_ack('80','001',{'len_msg'=>0,'subcommand'=>32777},2)!= 1)
      else
         raise(ProtocolError.new("Failed to Get All port list")) if (self.msg_with_ack('80','001',{'len_msg'=>0,'subcommand'=>32776},2)!= 1)
      end
      switch_list=parse_response()

      if (switch_list.nil?)
         @logger.debug "No switches where AVAILABLE=#{available}"
      else
         @logger.debug "switches AVAILABLE=#{available}"
         puts switch_list.msg_object().inspect()
         switch_list.msg_object()['rptp_list'].each { |switch|
            @logger.debug "SWITCH->#{switch}"
            puts "SWITCH->#{switch}"
         }
      end
      return switch_list.msg_object()['rptp_list']
   end

   def throttle(cpu_usage, frame_rate)
      raise(ProtocolError.new("Failed to Set Throttling")) if (self.msg_with_ack('90','001',{'resv1'=>0,'subcommand'=>20,'min_cpu_for_monitoring'=>50,'max_live_frame_rate'=>30},2)!= 1)

   end
   def monitor_with_callback(monitor_period,eavesdrop)
      #Analyzer.connection().reconnect!()
      #if !Analyzer.connected?()
      #@logger.debug "Not Connected!"
      #@logger.debug Analyzer.connection().inspect()
      #Analyzer.connection().reconnect!()
      #end
      @logger.debug "Eavesdrop #{eavesdrop}--------------------------------------------"
      if (eavesdrop)
         actual_mode=self.get_settings['actual_mode']
         if (actual_mode != 16)
            raise(ProtocolError.new("Not in Monitoring Mode"))
         end
      else
         self.set_mode(13)
         self.flush_alarms()
         self.flush_stats()
         self.start_monitoring()
         self.throttle(50,10)
      end
      continue_monitoring=true

      #GET INITIAL STATUS
      while (continue_monitoring)
         msg_obj=self.poll_status_monitoring()
         @logger.debug "#{Time.now()} ALARM COUNT: #{msg_obj['alarm_count']} STAT COUNT: #{msg_obj['statistic_count']} INTEGRAL COUNT: #{msg_obj['integral_count']} MONITORING STATUS: #{msg_obj['monitoring_status']}"
         continue_monitoring=yield(self,msg_obj)

      end
      @logger.debug "We are stopping the monitoring"
      if (!eavesdrop)
         raise(ProtocolError.new("Failed to Stop Monitoring")) if (self.msg_with_ack('90','002',{'subcommand'=>2})!=1) #Stop Monitoring
         raise(ProtocolError.new("Failed to Change Mode")) if (self.msg_with_ack('94','002',{'desiredmode'=>13},2)!= 1)
      end
   end

   def monitor_client(monitor_period=3)
      #raise(ProtocolError.new  ("Failed to Change Mode")) if (self.msg_with_ack('94','001',{'desiredmode'=>0},2)!= 1)
      #raise(ProtocolError.new  "Failed to Get Settings")) if (self.msg_with_ack('20','001',{'len'=>0,'subcommand'=>1,'resv1'=>0},3)!=1)
      #response_packet=read_response()
      #response=AvantronRec.parsePacket(response_packet,true)
      @logger.debug "Setting MODE"
      self.set_mode(13)
      @logger.debug "Flush Alarms"
      self.flush_alarms()
      @logger.debug "Flush Stats"
      self.flush_stats()
      @logger.debug "Start Monitoring"
      self.start_monitoring()
      @logger.debug "Set Throttle"
      self.throttle(50,10)

      #GET INITIAL STATUS
      time_marker=Time.now()
      @logger.debug "Set Time monitor and then kick off the poll"
      while (Time.now()-time_marker)< monitor_period
         msg_obj=self.poll_status_monitoring()
         @logger.debug "ALARM COUNT: #{msg_obj['alarm_count']} STAT COUNT: #{msg_obj['statistic_count']} INTEGRAL COUNT: #{msg_obj['integral_count']} MONITORING STATUS: #{msg_obj['monitoring_status']}"
         alarm_count=msg_obj['alarm_count'].to_i
         stat_count=msg_obj['statistic_count'].to_i
         while ( stat_count > 0 )
            @logger.debug "Getting Stats"
            self.next_stat()
            #TODO do something with the msg_obj
            msg_obj=response.msg_obj()
            stat_count=msg_obj{numb_of_xmit_stastics}.to_i
         end
         while ( alarm_count > 0 )
            @logger.debug "Getting Alarms #{alarm_count}"
            self.next_alarm()
            #TODO do something with the msg_obj
            msg_obj=response.msg_obj()
            @logger.debug("RESPONSE  #{response.msg_type.to_s}#{response.msg_obj()['subcommand']}")
            alarm_count=msg_obj["numb_of_xmit_alarms"].to_i
            @logger.debug "Now at #{alarm_count}"
         end
         raise(ProtocolError.new("Failed to Get SERIAL")) if (self.msg_with_ack('90','002',{'subcommand'=>15, 'resv1'=>255},0)!=1)
         
         response=parse_response()
         raise(ProtocolError.new("Did not get a STATUS Response #{response.inspect}")) if ((response.msg_type.to_i != 90) && (response.msg_obj()['subcommand'].to_i()!=15))

      end
      raise(ProtocolError.new("Failed to Stop Monitoring")) if (self.msg_with_ack('90','002',{'subcommand'=>2})!=1) #Stop Monitoring
      raise(ProtocolError.new("Failed to Change Mode")) if (self.msg_with_ack('94','002',{'desiredmode'=>13},2)!= 1)
   end
   def close_session()
      if !@socket.nil?
         @logger.debug "Closing Session"
         @socket.close
         @socket=nil
      end
   end
   def get_mode()
      return nil
   end
   def set_mode(mode)
      if (self.msg_with_ack('94','001',{'desiredmode'=>mode},1)!=1)
         @logger.debug "Sorry Mode #{mode} must not be supported!"
      end
   end
   def set_switch(switch)
      if (self.msg_with_ack('80','001',{'len_msg'=>0,'rptp_number'=>switch},1)!=1)
         @logger.debug "Sorry Switch #{switch} cannot be changed to"
				 return false
      end
		 return true
   end

   def login
      @logger.debug "LOGIN"
      raise(ProtocolError.new("Failed to Login to instrument")) if (self.msg_with_ack('03','001',{'resv1'=>0},1)!=1)
   end
   def do_dcp
      raise(ProtocolError.new("Failed to do DCP")) if (self.msg_with_ack("8","001",{"do_measures"=>1, "resv"=>16, "meas_result"=>0.0, "len"=>0},1)!=1)
      response=parse_response()
      if response.nil?
        @logger.debug "DCP response is nil"
         return nil
      end
      return response.msg_obj()
   end
   def analog_trigger(tcount=1,buffer_reset=0)
      raise(ProtocolError.new("Failed to Trigger")) if (self.msg_with_ack('98','001',{'trace_count_to_perform'=>tcount,
      'acquisition_buffer_reset'=>buffer_reset },1)!=1)
      response=parse_response()
      if (response.nil?)
         @logger.debug "Trigger Response is nil"
         return nil
      end
         return response.msg_obj()
   end
   def get_modulation()
      raise(ProtocolError.new("Failed to Get Modulation")) if (self.msg_with_ack('12','001',{'pkt_len'=>4,'subcommand'=>1,'resv'=>0,'ratio'=>0,'modulation'=>0}))
      response=parse_response()
      if (response.nil?)
         @logger.debug "Modulation Response is nil"
         return nil
      end
         return response.msg_obj()
   end
   def get_server_info()
      raise(ProtocolError.new("Failed to Get Server Info")) if (self.msg_with_ack('20','001',{'len'=>0,'subcommand'=>12,'resv1'=>0})!=1)
      response=parse_response()
      if (response.nil?)
         @logger.debug "Get Server Info."
         return nil
      end
         return response.msg_obj()
   end
   def get_hmlist()
      raise(ProtocolError.new("Failed to Get Server Info")) if (self.msg_with_ack('20','001',{'len'=>0,'subcommand'=>20,'resv1'=>0})!=1)
      response=parse_response()
      if (response.nil?)
         @logger.debug "Get Server Info."
         return nil
      end
         return response.msg_obj()
   end
   def digital_trigger(tcount=1,buffer_reset=0)
      raise(ProtocolError.new("Failed to Trigger")) if (self.msg_with_ack('98','001',{'trace_count_to_perform'=>tcount,
      'acquisition_buffer_reset'=>buffer_reset },1)!=1)
      response=parse_response()
      if (response.nil?)
         @logger.debug "Trigger Response is nil"
         return nil
      end
      result=response.msg_obj()
	  unless result[:points].nil?
		  points=result[:points].unpack("c*")  
		  result[:point_list]=points
		  return response.msg_obj()
	  end
	  return nil
   end
   def logout
      raise(ProtocolError.new("Failed to Logoff to instrument")) if (self.msg_with_ack('04','001',{'resv1'=>0},1)!=1)
   end

   def get_file_crc32(filename)
      if (self.msg_with_ack('20','002',
         {
            'subcommand'=>18,
            'len'=>0,
            'resv1'=>0,
            'filename'=>filename
         })!=1)
         raise(ProtocolError.new("Failed to get file crc32"))
      end
      response=parse_response()
      return response
   end

   def get_source_settings(source)
      @logger.debug "Get Source Settings"
      raise(ProtocolError.new("Failed to Get Source Settings")) if (self.msg_with_ack('90','002',{'subcommand'=>19,'resv1'=>0,'signal_source'=>source},0)!=1) #Flush Alarms
      @logger.debug "Starting To READ"
      response=parse_response()
      return response
   end
   def flush_alarms
      raise(ProtocolError.new("Failed to Flush Alarms")) if (self.msg_with_ack('90','002',{'subcommand'=>8},0)!=1) #Flush Alarms
   end
   def flush_stats
      raise(ProtocolError.new("Failed to Flush Stats")) if (self.msg_with_ack('90','002',{'subcommand'=>9},0)!=1) #Flush Stats
   end
   def start_monitoring(opt = :exception)
      raise(ProtocolError.new("Failed to Start Monitoring")) if ((self.msg_with_ack('90','002',{'subcommand'=>1})!=1) && (opt != :no_exception))#Start Monitoring
   end
   def stop_monitoring(opt = :exception)
      @logger.debug "Failed to Stop Monitoring" if ((self.msg_with_ack('90','002',{'subcommand'=>2})!=1) && (opt != :no_exception)) #Stop Monitoring
      set_mode(0)
   end
   def poll_status_monitoring
      if (self.msg_with_ack('90','002',{'subcommand'=>7, 'resv1'=>255},0)!=1)
         raise(ProtocolError.new( "Failed to POLL analyzer, Is analyzer still connected." ))
      end
      response=parse_response()
      if ((response.msg_type.to_i != 90) || (response.msg_obj()['subcommand'].to_i()!=45))
         raise ProtocolError.new(
            "Message type '#{response.msg_type.to_s}' is not valid")
      end
      return response.msg_object()
   end
   def get_date_time
      raise(ProtocolError.new("Failed to Get Date Time")) if (self.msg_with_ack('20','002',{'len'=>0,'subcommand'=>5, 'resv1'=>0},0)!=1)
      response=parse_response(10,20)
      return response.msg_object()
   end
   def get_settings
      raise(ProtocolError.new("Failed to Get Settings")) if (self.msg_with_ack('20','002',{'len'=>0,'subcommand'=>1, 'resv1'=>0},0)!=1)
      response=parse_response(10,20)
      if ((response.msg_type.to_i == 20) && (response.msg_obj()['subcommand'].to_i()==1))
         return response.msg_object()
      end
   end
   def set_settings(new_settings)
      #First Get the settings from the instrument.
      orig_settings=get_settings()
      settings=orig_settings.dup
      raise(ProtocolError.new("Set Setting parameter must be a hash")) unless new_settings.is_a?(Hash)
      new_settings.each_key { |key|
         if !settings.has_key?(key)
            raise(ProtocolError.new("Setting #{key} is not recognized"))
         end
         settings[key]=new_settings[key]
      }
      #@logger.debug "-----------------------"
      settings['subcommand']=2
      raise(ProtocolError.new("set the settings")) if (self.msg_with_ack('20','002',settings,0)!=1) #Start Monitoring
      read_settings=get_settings()
      read_settings.delete("subcommand")
      settings.delete("subcommand")
      return settings
   end
   def flood_config(cycle_count,alarm_flood_thresh,flood_restore_cycle)
      @logger.debug "Flood Config"
      raise(ProtocolError.new("Failed to Flood Config")) if (self.msg_with_ack('90','002',
                {'subcommand'=>23,'cycle_count'=>cycle_count,'alarm_flood_thresh'=>alarm_flood_thresh,'flood_restore_cycle'=>flood_restore_cycle}
         )!=1) #reset_error
   end
   def clear_monitoring_error
      @logger.debug "Clearing Error"
      raise(ProtocolError.new("Failed to Start Monitoring")) if (self.msg_with_ack('90','002',{'subcommand'=>14})!=1) #reset_error
   end
   def next_stat
      raise(ProtocolError.new("Failed to NEXT STAT")) if (self.msg_with_ack('90','002',{'subcommand'=>12},0)!=1)
      response=parse_response()
      raise(ProtocolError.new("Did not get a STAT Response #{response.inspect}")) if ((response.msg_type.to_i != 90) || (response.msg_obj()['subcommand'].to_i()!=48) )
      return response
   end
   def next_alarm
      next_alarm_result=self.msg_with_ack('90','002',{'subcommand'=>22},0)
      if (next_alarm_result == 1)
         response=parse_response()
         raise(ProtocolError.new("Did not get a ALARM Response #{response.inspect}")) if ((response.msg_type.to_i != 90) && ((response.msg_obj()['subcommand'].to_i()!=46) && (response.msg_obj()['subcommand'].to_i()!=47)))
         if (response.msg_obj()['subcommand'].to_i() != 46)
            @logger.debug "Got an alarm Trace"
         end
         return response
      elsif (next_alarm_result==0)
         @logger.debug("Next Alarm got a Nack")
      elsif (next_alarm_result.nil?)
         @logger.debug("No Acknowledgement of next alarm")
      end
   end
   def get_instrument_settings
   end
   def set_working_mode(streaming)
      raise(ProtocolError.new("Failed to Set WorkingMode")) if (self.msg_with_ack('90','002',{'subcommand'=>17,'mode_on'=>streaming},0)!=1)
   end
   def select_request(node)
      raise(ProtocolError.new("Failed to Select Requested")) if (self.msg_with_ack('90','002',{'subcommand'=>16,'status'=>1,'src_nbr'=>node},0)!=1)
      response=parse_response()
   end
   def select_request_list(node_list)
      node_list.each { |node|
         @logger.debug "Activating Nodes #{node}"
         raise(ProtocolError.new("Failed to Select Requested")) if (self.msg_with_ack('90','002',{'subcommand'=>16,'status'=>1,'src_nbr'=>node},0)!=1)
      }
   end

end
