#!/usr/bin/env ruby

require 'open3'

class IPTables
  
  PATH = "/sbin"
  if File.exist?("#{PATH}/iptables")
    # Existing path will work, do nothing
  elsif File.exist?("/usr#{PATH}/iptables")
    PATH = "/usr#{PATH}"
  else
    raise "Unable to find path to iptables"
  end
  @@ipt="/usr/bin/sudo #{PATH}/iptables -t nat"
  @@iptSave="/usr/bin/sudo #{PATH}/iptables-save -t nat"
  @@iptRestore="/usr/bin/sudo #{PATH}/iptables-restore" 
  @@tmpFile="/tmp/iptinfo." + $$.to_s
  @@port="3001"

  # save format
  #-A PREROUTING -p tcp --dst $LOCAL_IP --dport $LPORT -j DNAT --to-destination $DEST_IP:$DEST_PORT
  #-A POSTROUTING -p tcp --dst $DEST_IP --dport $DEST_PORT -j SNAT --to-source $LOCAL_IP
   def IPTables.getIpByHostname(hostname)
       ipaddr=IPSocket.getaddress(hostname)
       return ipaddr
   end
   def IPTables.my_ip
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

  def IPTables.sync_iptables_rules(list,logger) 
    unless list.kind_of?(Hash)
      logger.error "sync_iptables_rules requires a hash of ports -> ip"
      return
    end
    f=File.new(@@tmpFile, "w")
    f.puts '*nat'
    list.each { |iptables_port, ip|
      if ip !~ /^(\d+\.)3\d+$/
         ip = IPTables.getIpByHostname(ip)
      end
      #  cmd_list.push "-A PREROUTING -p tcp -m tcp --dport #{iptables_port} -j DNAT --to #{ip}:#{p}"
      logger.info "Adding forward on port #{iptables_port} to #{ip}"
      f.puts "-A PREROUTING -p tcp -m tcp --dport #{iptables_port} -j DNAT --to #{ip}:#{@@port}"
    }
    f.puts "COMMIT"
    f.close
    #cmd_list.push "COMMIT"
    sys_call="cat #{@@tmpFile} | #{@@iptRestore}"
    logger.info sys_call
    Open3.popen3("#{sys_call}") { |stdin, stdout, stderr|
      err=stderr.read
      unless err.empty?
        logger.error "#{err}"
      end
    }
  end
  def IPTables.check(logger)
    err=""
    dnat_hash={}
    snat_hash={}
    dup_dnat_list=[]
    dup_snat_list=[]
    my_ip=IPTables.my_ip
    puts my_ip
    logger.info sys_call
    sys_call="#{@@ipt} -L -n --line-numbers"
    Open3.popen3("#{sys_call}") { |stdin, stdout, stderr|
      err=stderr.read
      unless err =~ /^\s*$/
        logger.error "#{err}"
        return {"err" => "#{err}"}
      end
     
      stdout.each { |line|
         #puts line
         if line =~ /^(\d+)\s+DNAT.*#{my_ip}\s+tcp\s+dpt:(\d+)\s+to:((\d{1,3}\.){3}\d{1,3}):\d+\s*$/
            dest_ip=$3
            fwd_port=$2
            index=$1
            if dnat_hash.has_key?(dest_ip)
               logger.debug "found dup #{dest_ip}:#{fwd_port}"
               dup_dnat_list.push(dest_ip)
            end
            dnat_hash[dest_ip]={"index" => index, "port" => fwd_port}
         end
         if line =~ /^(\d+)\s+SNAT.*((\d{1,3}\.){3}\d{1,3})\s+tcp\s+dpt:\d+\s+to:#{my_ip}:(\d+)\s*$/
            dest_ip=$2
            fwd_port=$4
            index=$1
            # do I need tocompare the dups ??? TODO
            if snat_hash.has_key?(dest_ip)
               logger.debug "found dup #{dest_ip}:#{fwd_port}"
               dup_snat_list.push(dest_ip)
            end
            snat_hash[dest_ip]={"index" => index, "port" => fwd_port}
         end
      }
    }
    puts "check for dups"
    dup_dnat_list.each { |ip|
        IPTables.delete_iptables_rule(ip, logger)
        logger.info "deleted #{ip}"
    }
  end
          
  def IPTables.call_iptables(opts, logger)
     err=""
     Open3.popen3(opts) { |stdin, stdout, stderr|
       err=stderr.read
     } 
     if err
       logger.error err
       return true  
     end
     return true
  end
           
  def IPTables.delete_iptables_rule(ip_to_delete, logger ) 
     if ip_to_delete !~ /^(\d+\.)3\d+$/
        ip_to_delete = IPTables.getIpByHostname(ip_to_delete)
     end
     err = ""
     pre_line_to_del=""
     post_line_to_del=""
     sys_call = @@ipt + " -n -L --line-numbers"
     logger.info sys_call
     # get dump of NAT table with line number index
     Open3.popen3(sys_call) { |stdin, stdout, stderr|
        stdout.each_line() { |line|
           # find matching line
           if line=~ /^(\d+)\s+DNAT.*to:#{ip_to_delete}:\d+\s*$/ 
              pre_line_to_del=$1
           end
           if line=~ /^(\d+).*SNAT.*#{ip_to_delete}/ 
              post_line_to_del=$1
           end
        }
     }
      # no line found for that ip addy
      if pre_line_to_del.empty?
        logger.warn "delete_iptables_rule called to delete #{ip_to_delete}, no rule found"
      end
      sys_call = @@ipt + " -D PREROUTING #{pre_line_to_del}"
      logger.info sys_call
      IPTables.call_iptables(sys_call, logger)
      
      # no line found for that ip addy
      if post_line_to_del.empty?
        logger.warn "delete_iptables_rule called to delete #{ip_to_delete}, no rule found"
      end
      sys_call = @@ipt + " -D POSTROUTING #{post_line_to_del}"
      logger.info sys_call 
      IPTables.call_iptables(sys_call, logger)
     
      return 
      
  end
	
  def IPTables.add_iptables_rule(ip, iptables_port, logger )
     if ip !~ /^(\d+\.)3\d+$/
        ip = IPTables.getIpByHostname(ip)
     end
     err=""
     my_ip=IPTables.my_ip
     sys_call=@@ipt + " -A PREROUTING -p tcp --dst #{my_ip} --dport #{iptables_port} -j DNAT --to #{ip}:#{@@port}"
     logger.info "IPTables.add_iptables_rule calling #{sys_call}"
     IPTables.call_iptables(sys_call, logger)
     sys_call=@@ipt + " -A POSTROUTING -p tcp --dst #{ip} --dport #{@@port} -j SNAT --to-source #{my_ip}"
     logger.info "IPTables.add_iptables_rule calling #{sys_call}"
     IPTables.call_iptables(sys_call, logger)
     return true
  end
end

