class Analyzer < ActiveRecord::Base
  require 'iptables.rb'
  has_many                :datalog_profiles, :order => "limit_val, name", :dependent => :destroy
  has_many                :system_logs
  has_one                 :schedule, 
                          :dependent => :destroy
  has_many                :cfg_channels,
                          :dependent => :destroy
  has_many                :switches, 
                          :order=> "address", 
                          :dependent => :destroy

  belongs_to              :site
  belongs_to              :profile
  belongs_to              :laser_clip_profile , :foreign_key => "laser_clip_profile_id", :class_name => "Profiles"
  
  #Commented out temporarily. Only needed for realview.
  #validates_uniqueness_of :hmid 
  validates_uniqueness_of :name
  validates_uniqueness_of :ip
  validates_presence_of   :name
  validates_format_of     :name,
                          :with =>/\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i
  validates_format_of     :api_url,
                          :with =>/(^(javascript:|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)|^about:blank$|^$/ix  
  validates_presence_of   :ip
  validates_format_of     :ip,
                          :with =>/^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/
  validates_format_of     :email,
                          :with => /(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z|^$)/i#,
#                          :if => Proc.new { |analyzer|analyzer.email.length >0 }     
  validates_length_of     :name, :within => 1..19,
                          :too_long =>"please enter at most %d character",  
                          :too_short=>"please enter at least %d character"
  validates_numericality_of :start_freq, :greater_than_or_equal_to => 0, :allow_nil =>true, :only_integer => true, :less_than => 1500000001
  validates_numericality_of :stop_freq, :less_than => 1500000001, :allow_nil =>true, :only_integer => true, :greater_than_or_equal_to => 0
  validates_presence_of   :region_id,
                          :message=>"has not been select. Please select a region first,If you can't, Please create one." 
#  before_destroy          :delete_analyzer_ip
#  before_save             :add_analyzer_ip
   before_create           :generate_site
   before_save             :update_site

  DISCONNECTED=10
  CONNECTED=11
  INGRESS=12
  DOWNSTREAM=13
  PROCESSING=14
  SWITCHING=15

  def generate_site
    
    site_name=read_attribute(:name)
    self.site_id=Site.create_if_needed(site_name)
    if self.site_id.nil?
      raise "Failure to generate site for analyzer." + site.errors().full_messages().join(',')
    end
    self.site_id=site.id
  end
  def update_site
    site_name=read_attribute(:name)
    if self.site_id.nil?
      generate_site
    end
#    site=Site.find(self.site_id)
#    site.name=site_name
#    if !site.update_attributes({:name => site_name})
#      raise "Failure to update site for analyzer." + site.errors().full_messages().join(',')
#    end
  end
  def get_max_iteration
  end
  def validate
    if (!start_freq.nil? && stop_freq.nil?) || (start_freq.nil? && !stop_freq.nil?)
      errors.add("start_freq", "Both Start freq. and Stop freq. must be empty or both be set")
    elsif !start_freq.nil? && (start_freq > stop_freq)
      errors.add("start_freq", "Start freq. must be less than Stop freq.")
    end
  end
  def noise_floor_low_disp=(x)
     write_attribute(:nf_low,(x.to_f*1_000_000).to_i)
  end
  def noise_floor_high_disp=(x)
     write_attribute(:nf_high,(x.to_f*1_000_000).to_i)
  end
  def noise_floor_low_disp()
    if nf_low.nil?
      return nil
    else
      return read_attribute(:nf_low)/1000000.0
    end
  end
  def noise_floor_high_disp()
    if nf_high.nil?
      return nil
    else
      return read_attribute(:nf_high)/1000000.0
    end
  end
  def noise_floor_start_freq_disp=(x)
     write_attribute(:nf_start_freq,(x.to_f*1_000_000).to_i)
  end
  def noise_floor_stop_freq_disp=(x)
     write_attribute(:nf_stop_freq,(x.to_f*1_000_000).to_i)
  end
  def noise_floor_start_freq_disp()
    if nf_start_freq.nil?
      return nil
    else
      return read_attribute(:nf_start_freq)/1000000.0
    end
  end
  def noise_floor_stop_freq_disp()
    if nf_stop_freq.nil?
      return nil
    else
      return read_attribute(:nf_stop_freq)/1000000.0
    end
  end
  def start_freq_disp=(x)
     write_attribute(:start_freq,(x.to_f*1_000_000).to_i)
  end
  def stop_freq_disp=(x)
     write_attribute(:stop_freq,(x.to_f*1_000_000).to_i)
  end
  def start_freq_disp()
    if start_freq.nil?
      return nil
    else
      return read_attribute(:start_freq)/1000000.0
    end
  end
  def stop_freq_disp()
    if stop_freq.nil?
      return nil
    else
      return read_attribute(:stop_freq)/1000000.0
    end
  end
  def get_site
    if site.nil?
      return nil
    end
    return site
  end
  def delete_analyzer_ip(ip = self.ip, iptables_port = self.iptables_port)
    logger.info "Calling kenry's remove code with #{ip} #{iptables_port}"
    # Call Kenry's remove code with ip, iptables_port
    IPTables.delete_iptables_rule(ip,logger) 
  end
  def add_analyzer_ip
    if self.new_record?
      # We're a new record, so generate a iptables_port
      if self.iptables_port.nil? || self.iptables_port.eql?("unk")
        logger.info "Calling jason's add code with #{self.ip} #{self.iptables_port}"
        self.iptables_port = Analyzer.calculate_iptables_port
        if self.iptables_port.nil?
          return false
        end
      end
      # Just to be sure, make sure the port is not nil
      if self.iptables_port.nil?
        return false
      end
    else
      # We're doing an update of an existing analyzer.
      # Check to see if they changed the IP address.
      analyzer = Analyzer.find(self.id)
      if analyzer.ip != self.ip
        # They changed it, delete the old iptables rule
        logger.info "IP changed from #{analyzer.ip} to #{self.ip}, calling delete"
        delete_analyzer_ip(analyzer.ip, analyzer.iptables_port)
        self.iptables_port = analyzer.iptables_port
      else
        # It's the same IP address, nothing to see here, move along
        return
      end
    end
    logger.info "Calling kenry's add code with #{self.ip} ..#{self.iptables_port} #{self.iptables_port.class}.."
    # Call Kenry's add code with self.ip, self.iptables_port
    IPTables.add_iptables_rule(self.ip, self.iptables_port,logger)
  end
  def Analyzer.hash_iptables_port
    analyzers = Analyzer.find(:all)
    ports = analyzers.inject({}) { |hash, analyzer|
      hash["#{analyzer.iptables_port}"] = analyzer.ip
      hash
    }
    return ports
  end
  def Analyzer.calculate_iptables_port
    ################
    # calculate_iptables_port
    # Finds the iptables port for live trace.
    ################
    startPort = ConfigParam.get_value("Iptables Start Port")
    stopPort = ConfigParam.get_value("Iptables Stop Port")
    ports = Analyzer.hash_iptables_port
    myPort = startPort
    while(myPort < stopPort)
      logger.info "Checking #{myPort} #{ports[myPort.to_s]}"
      if ports[myPort.to_s].nil?
        return myPort
      end
      myPort += 1
    end
    # No available ports
    return nil
  end
  def get_switch_port(calculated_port)
    ################
    # get_switch_port
    # Returns the switch port for a port number
    ################
    first_switch=switches.first
    if (first_switch.nil?)
      raise "No Switches Exist"
    else
      if !switches.find(:first,:conditions=>["master_switch_flag=?",1]).nil? #If master switch exist
        switch_src=((calculated_port-1) / port_count).to_i+2
      else
        switch_src=((calculated_port-1) / port_count).to_i+1
      end
      port_nbr=((calculated_port-1) % port_count)+1
      target_switch=switches.find(:first, :conditions=>["address=?",switch_src])
    end
    if target_switch.nil?
      raise "Cannot find switch for Port #{calculated_port} with port count #{port_count} and port_nbr #{port_nbr}"
    end
    switch_port=target_switch.switch_ports.find(:first,
      :conditions=>["port_nbr=?",port_nbr])
    if switch_port.nil?
      raise "Could not find switch_port for #{port_nbr}"
    end
    return switch_port.id
  end
  def get_port_list
    ################
    # get_port_list
    # Returns a list of ports for analyzer.
    # TODO. Please verify this works with a master switch
    ################
    port_list= Array.new
    self.switches.each {|switch|
      switch.switch_ports.each { |switch_port|
          port={}
          port[:port_nbr]=switch_port.get_calculated_port()
          port[:port_id]=switch_port.id
          port[:site_id]=switch_port.site_id
          port_list.push(port)
      }
    }
    return port_list
  end
  def get_status()
    ################
    # get_status
    # Returns status.  If status field is nil then default to disconnected.
    ################
    if status.nil?
      return DISCONNECTED
    end
    return status
  end
  def clean_name
    ################
    # clean_name
    # Replaces spaces with underscores.
    ################
    unless self.nil?
      return self.name.gsub(/ /, '_')
    end
  end
  def Analyzer.status_to_str(status,analyzer_id=nil)
    ################
    # status_to_str
    # Returns a string version of analyzer's status.
    ################
    if status.to_i==DISCONNECTED
      if analyzer_id != nil
        exception_str=Analyzer.find(analyzer_id).exception_msg
      else
        exception_str=""
      end
      if !exception_str.nil? && exception_str.length > 0
        return "DISCONNECTED {#{exception_str}}"
      else
        return "DISCONNECTED "
      end
      return "DISCONNECTED" 
    elsif status.to_i==CONNECTED
      return "CONNECTED"
    elsif status.to_i==INGRESS
      return "INGRESS MONITORING"
    elsif status.to_i==DOWNSTREAM
      return "DOWNSTREAM MONITORING"
    elsif status.to_i==PROCESSING
      if analyzer_id != nil
        progress_str=Analyzer.find(analyzer_id).progress
        if progress_str.length >0
          return "PROCESSING {#{progress_str}}"
        else
          return "PROCESSING "
        end
      end
    else 
      return "MAINTENANCE"
    end
  end
  def clear_exceptions
    ################
    # clear_exceptions
    # Blank out exception string
    ################
    update_attribute(:exception_msg,"")
  end
  def clear_progress
    ################
    # clear_progress
    # Blank out progress field
    ################
    update_attribute(:progress,"")
  end
  def Analyzer.errcode_lookup(errcode)
    ################
    # errcode_lookup
    # converts error codes from analyzer to string
    ################
    errcode=errcode.to_i
    case errcode
      when 240
        return "Switch Error."
      when 241
        return "RPTP Select Error."
      when 254
        return "Disk is full."
      else
        return "Unrecognized Error code #{errcode}"
    end
  end
  def get_all_sites
    #############
    #get_all_sites
    #Get all the sites associated with this analyzer.
    #############
    site_list=[]
    site_list.push(site)
    switches.each { |switch|
      next if switch.nil?
      switch.switch_ports.each { |switch_port|
        site_list.push(switch_port.site)
      }
    }
    return site_list.compact
  end
  def has_ingress_data
	indata=Site.find_by_sql("select distinct dl.site_id from (switch_ports as sp inner join datalogs as dl on dl.site_id = sp.site_id) inner join switches as sw on sp.switch_id = sw.id where sw.analyzer_id ='#{self.id}'")
    if indata.length == 0
		return false
	else
		return true
	end
  end
  def has_downstream_data
	dwdata=Site.find_by_sql("select distinct mr.site_id from (switch_ports as sp inner join measurements as mr on mr.site_id = sp.site_id) inner join switches as sw on sp.switch_id = sw.id where sw.analyzer_id ='#{self.id}'")
    if dwdata.length == 0
		return false
	else
		return true
	end
  end
  def drop_ingress_data
	dl=Datalog.find_by_sql("select * from datalogs where site_id in (select distinct sp.site_id from switch_ports as sp inner join switches as sw on sw.id = sp.switch_id where sw.analyzer_id = '#{self.id}')")
    Datalog.destroy(dl)
	al=Alarm.find_by_sql("select * from alarms where site_id in (select distinct sp.site_id from switch_ports as sp inner join switches as sw on sw.id = sp.switch_id where sw.analyzer_id = '#{self.id}')")
	Alarm.destroy(al) unless al.length == 0
  end
  def drop_downstream_data
	ms=Measurement.find_by_sql("select * from measurements where site_id in (select distinct sp.site_id from switch_ports as sp inner join switches as sw on sw.id = sp.switch_id where sw.analyzer_id = '#{self.id}')")
	Measurement.destroy(ms)
	da=DownAlarm.find_by_sql("select * from down_alarms where site_id in (select distinct sp.site_id from switch_ports as sp inner join switches as sw on sw.id = sp.switch_id where sw.analyzer_id = '#{self.id}')")
	DownAlarm.destroy(da) unless da.length == 0
  end
  
  before_destroy { |analyzer| Site.destroy_all(["id in (?)",analyzer.get_all_sites.collect{|site|site.id}])   }  
end
