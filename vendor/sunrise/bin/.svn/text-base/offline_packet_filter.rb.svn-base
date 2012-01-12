#!/usr/bin/env ruby

# this line imports the libpcap ruby bindings
require 'pcaplet'
$:.push(File.expand_path(File.dirname(__FILE__))+"/../lib")
puts $:
#require 'common'
require 'avantron'
include Avantron

$LOG=Logger.new('offline.log')
$LOG.debug("STARTING RW CLIENT")

filename=ARGV[0]
server_port=ARGV[1] || 3201
puts "Loading #{filename}...."
network=Pcap::Capture.open_offline(filename)
buffer="";

fil=open('sample_file','w')
# iterate over every packet that goes through the sniffer
packet_counter=0
for p in network
   # print packet data for each packet that matches the filter
   if p.tcp? && (p.sport.to_i == server_port.to_i || p.dport.to_i==server_port.to_i)
   puts p.sport
     packet_counter +=1
     if p.tcp_data.nil?
       next
     end
      puts (p.dport.to_i == server_port.to_i ? "TO ANALYZER" : "FROM ANALYZER ")
     buffer << p.tcp_data
     endpos=0;
     while (!endpos.nil?)
       endpos=(buffer=~/\003\004/)
       if endpos.nil?
         next
       end
       data=buffer.slice!(0..endpos+1)
     
       puts "Packet Counter #{packet_counter} TOP:#{p.time} DATA LENGTH:#{data.inspect()}"
       puts  "SOURCE #{p.sport.to_s()} DEST: #{p.dport.to_s()}"
       begin
        result=AvantronRec.parsePacket(data, p.sport.to_i == server_port.to_i, $LOG)
       rescue Exception => e
        puts e.message()
        puts p.inspect()
        puts e.inspect()
        puts e.backtrace()
        result=nil
       end
        fil.write("#{p.src=='192.168.0.102'} #{p.tcp_data}\n")
        if (!result.nil?)
           if !result.msg_object.nil?
             #idx=0
           end
           puts "[******************************"
           puts "Packet Counter #{packet_counter}" + result.inspect()
           puts result.inspect()
			  else
				  puts "Unrecognized Packet #{p.tcp_data.inspect}"
        end
     
       puts "___________________________________________________________________________"
     end
   end
end
fil.close
