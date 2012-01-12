#!/usr/bin/env ruby

require "open3"
require "socket"

class GetIpaddr
   def GetIpaddr.my_ip
      ipaddr=''
      ifcfg="/sbin/ifconfig"
      cmd="#{ifcfg} | grep 'inet addr'"
      Open3.popen3(cmd) { |stdin, stdout, stderr|
         stdout.each_line() { |line|
            if ( line=~ /inet addr:((\d{1,3}\.){3}\d{1,3})\s/ )
               ipaddr=$1
               ipaddr
               break 
            end
         }
      }
      return ipaddr
   end
   def GetIpaddr.byHostname
      hostname='gluttony'
      ipaddr=IPSocket.getaddress(hostname)
      return ipaddr
   end
end

