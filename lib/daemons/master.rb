#!/usr/bin/env ruby

$:.push(File.expand_path(File.dirname(__FILE__))+"/../../vendor/sunrise/lib")

require File.dirname(__FILE__) + "/../../config/environment"
require 'common'
require 'config_files'
require 'webrick/httprequest'
require 'webrick/httpresponse'
require 'webrick/config'
require 'net/http'
ENV["RAILS_ENV"] ||= "development"

$running = true;
Signal.trap("TERM") do
   $running = false
end

$logger=Logger.new(File.join(File.dirname(__FILE__) ,'../../log/master.out'))

class Master
   # ===initialize
   # Creates the Master class
   def initialize(port, start_port, stop_port)
      $logger.debug("Monitor Application Restarting #{DateTime.now().to_s}")
      @port=port
      @start_port=start_port
      @stop_port=stop_port
      @ports_analyzer=[]
   end
   # ===main
   # Main function with main loop.
   def main
      #server=TCPServer::new('10.0.0.60',port)
      @server=TCPServer::new(@port)
      $logger.debug "Running on Port #{@port}"
      begin
         if defined?(Fcntl::FD_CLOEXEC)
            @server.fcntl(Fcntl::FD_CLOEXEC,1)
         end
         @server.listen(5)
         #@sock=@server.accept_nonblock
      rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO, Errno::EINTR
         IO.select([@server])
         retry
      end
      Analyzer.find(:all).each { |analyzer|
         # If on start if analyzer is in downstream mode and ingress then restart the processl
         if (analyzer.cmd_port.nil?) && ((analyzer.status == Analyzer::INGRESS) || (analyzer.status == Analyzer::DOWNSTREAM))
            port=get_port(analyzer.id)
            $logger.error "We don't have a port number for #{analyzer.id}, assigning it #{port}"
            analyzer.update_attributes({:cmd_port=>port})
         elsif (!analyzer.cmd_port.nil?) && ((analyzer.status == Analyzer::INGRESS) || (analyzer.status == Analyzer::DOWNSTREAM))
            @ports_analyzer[analyzer.cmd_port - @start_port]=analyzer.id
            $logger.debug "Setting cmd port #{analyzer.cmd_port}"
         end
         #analyzer.update_attributes({:status=>Analyzer::DISCONNECTED})
      }
      an_count=Analyzer.find(:all).size
      try_count=Array.new(an_count,0)
      while(1)
         Analyzer.find(:all).each { |analyzer|
            if (!analyzer.cmd_port.nil?)
               @ports_analyzer[analyzer.cmd_port - @start_port]=analyzer.id
               try_count[analyzer.id]=0 if try_count[analyzer.id].nil?
               $logger.debug "Setting cmd port #{analyzer.cmd_port}"
            end
         }
         time=Time.now()
         selected_socket_list=IO.select([@server],nil,nil,5)
         if (selected_socket_list.nil?)
            $logger.debug "Nothing to send Do a heartbeat"
            #logger.debugs @ports_analyzer.inspect()
            @ports_analyzer.each_index { |port_index|
               analyzer_id=@ports_analyzer[port_index]
               port=nil
               if !analyzer_id.nil?
                  port=get_port(analyzer_id)
               end

               unless port.nil?
                  try_count[analyzer_id] +=1
                  request=Net::HTTP.new('localhost',port)
                  $logger.debug "Do a heartbeat on #{port}"
                  #tries=0
                  flag=true
                  begin
                     #sleep 5
                     #tries +=1
                     $logger.debug "TRY # #{try_count[analyzer_id]}"

                     response=request.get("/")
                  rescue Timeout::Error #Instrument not responding. Lets kill the process.
                     flag=false
                     anl=Analyzer.find(analyzer_id)
                     if (!anl.nil?) && (!anl.pid.nil?) && (anl.pid != 0)
                        Process.kill("TERM", anl.pid)
                     else
                        SystemLog.log("Unable to start monitoring process for Analyzer: #{anl.name}",nil,SystemLog::MESSAGE,analyzer_id)
                        anl.update_attribute({:pid=>0})
                     end
                  rescue
                     #sleep 5
                     #$logger.debug "Try again"
                     flag=false
                     if (try_count[analyzer_id] > 5)
                        try_count[analyzer_id]=0
                        $logger.debug "Restarting monitor for #{analyzer_id}"
                        SystemLog.log("(Re)Starting the monitor server #{Analyzer.find(analyzer_id).ip}",nil,SystemLog::MESSAGE,analyzer_id)
                        start_monitor(analyzer_id, port)
                     end
                  end
                  if flag==true
                     try_count[analyzer_id]=0
                  end
                  $logger.debug response.inspect()
               end
               diff=Time.now-time
               if diff < 5
                  sleep (5-diff)
               end
            }
         else
            selected_socket=selected_socket_list[0].first()
            @sock=selected_socket.accept
            process()
         end
      end
   end

   # _start_monitor
   # alternative start monitor script.  Have not been able to get to work.  Was suppose to use
   # daemon.rb class
   def _start_monitor(analyzer_id, port)
      $logger.debug "_START MONITOR"
      opts={
         :ARGV       => ['restart',analyzer_id.to_s,port.to_s],
         :multiple   => true,
         :monitor    => true,
         :backtrace  => true,
         :mode       => :exec,
         :log_output => File.join(File.dirname(__FILE__) ,'../../log/monitor.out')
      }
      script = File.join(File.dirname(__FILE__),"monitor.rb")
      #Child process execs
      #ObjectSpace.each_object(IO) {|io| io.close rescue nil }
      app = Daemons.run(script ,opts)
      $logger.debug "------------------------------------------->"
      $logger.debug app.inspect()
      $logger.debug "<-------------------------------------------"
      #parent process continues
   end
   # start_monitor
   # start monitor function.   This function launches the monitor.rb function.
   # daemon.rb class
   def start_monitor(analyzer_id, port)
      $logger.debug "START MONITOR"
      analyzer = Analyzer.find(analyzer_id)
      opts={
         :ARGV   => ['start',analyzer_id.to_s,port.to_s]
      }
      script = File.join(File.dirname(__FILE__),"monitor.rb")
      child_process = Kernel.fork()
      if (child_process.nil?)
         # In Child process
         @sock.close if (!@sock.nil?)
         @server.close if (!@server.nil?)
         stdfname  = File.join(File.dirname(__FILE__) ,"../../log/monitorstd_#{analyzer_id}")
         stdin     = open '/dev/null','r'
         stdout    = open stdfname+".out",'a'
         stderr    = open stdfname+".err",'a'
         $0        = sprintf("%s_%s_%s", $0, analyzer.ip, port)
         #STDIN.close
         #STDIN.reopen stdin
         STDOUT.reopen stdout
         STDERR.reopen stderr
         #STDIN.open('/dev/null')
         #STDOUT.open(stdfname,'a')
         #STDERR.open(stdfname,'a')
         Kernel.exec(script,analyzer_id.to_s,port.to_s)
         exit
      end
      #parent process continues
      Process.detach(child_process)
      $logger.debug "Monitor Forked"
   end

   # ===get_port
   # Looks up the TCP/IP port from the internal array by analyzer id

   def get_port(analyzer_id)
      @ports_analyzer.each_index { |index|
         if @ports_analyzer[index] == analyzer_id
            port_nbr=@start_port+index
            anl=Analyzer.find(analyzer_id)
            if !anl.nil?#Set port number in database when we assign it in array
               anl.update_attributes({:cmd_port=>port_nbr})
               return port_nbr
            end
         end
      }
      return nil
   end

   # ===get_port(analyzer_id)
   # Creates a port if none exist for an analyzer.
   def allocate_port(analyzer_id)
      if !get_port(analyzer_id).nil?
         raise "Tried to allocate a port for an analyzer that already exists"
      end
      len=@ports_analyzer.length
      if (len < (@stop_port-@start_port+1))
         @ports_analyzer[len]=analyzer_id
         return len+@start_port
      else
         @ports_analyzer.each_index { |index|
            if @ports_analyzer[index].nil?
               return index+@start_port
            end
         }
      end
   end
   # ===run(cmd,param)
   # Takes command sent to master.rb (GETPORT or RESET) and then
   # If GETPORT then we return the tcp/ip port number to the process that made a request to the master.rb
   def run(cmd, param)
      if cmd == 'GETPORT' || cmd == 'RESET'
         #Start server if not started
         analyzer_id=param.to_i
         anl_port_nbr=get_port(analyzer_id)
         if (anl_port_nbr.nil?)
            new_port=allocate_port(analyzer_id)
            if new_port.nil?
               SystemLog.log("Unable to allocate port",nil,SystemLog::ERROR,analyzer_id)
               raise "Not enough ports for server"
            end
            start_monitor(analyzer_id, new_port)
            return "PORT,#{new_port},NEW"
         else
            return "PORT,#{anl_port_nbr},EXISTING"
         end
      elsif (cmd == 'STATUS')
         return "OK"
      end
   end

   # ===process()
   # Processes the http request.
   def process()
      begin
         @sock.sync=true
         req=WEBrick::HTTPRequest.new(WEBrick::Config::HTTP.dup)
         res=WEBrick::HTTPResponse.new(WEBrick::Config::HTTP.dup)
         WEBrick::Utils::set_non_blocking(@sock)
         WEBrick::Utils::set_close_on_exec(@sock)
         req.parse(@sock)
         $logger.debug "PATH=#{req.path}"
         $logger.debug "QUERY=#{req.query_string}"
         args=req.path.split('/')
         cmd=args.last()
         str=run(cmd, req.query_string)
         res.request_method=req.request_method
         res.request_uri=req.request_uri
         res.request_http_version=req.http_version
         res.keep_alive=false
         res.body="Accepted,#{req.path},#{str}"
         res.status=200
         $logger.debug res.inspect()
         res.send_response(@sock)
      rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPROTO=>ex
      rescue Exception => ex
         raise ex.inspect()
      end
   end
end

begin
   port        = ConfigParam.find_by_name("Monitor Start Port").val.to_i
   start_port  = port + 1
   stop_port   = ConfigParam.find_by_name("Monitor Stop Port").val.to_i
rescue NoMethodError
   raise "One or more of your config params are invalid/null.  Fix this and restart."
   exit
end
mst         = Master.new(port, start_port, stop_port)
mst.main
