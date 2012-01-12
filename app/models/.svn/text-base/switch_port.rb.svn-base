class SwitchPort < ActiveRecord::Base
  RETURN_PATH = 1
  FORWARD_PATH = 2
  has_many :scheduled_sources, :dependent => :destroy
  belongs_to :switch
  belongs_to :site
  belongs_to :profile
  belongs_to :laser_clip_profile , :foreign_key => "laser_clip_profile_id", :class_name => "Profiles"
  validates_format_of     :name,
                          :with => /\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/,
                          :message => "You have input a wrong format of the name address."	
  validates_length_of :name, :within => 1..10,
                          :too_short=>"please enter at least %d character",
	                      :too_long =>"please enter at most %d character"
  
  validates_inclusion_of :purpose, :in => [SwitchPort::RETURN_PATH, SwitchPort::FORWARD_PATH], :allow_nil => true
   before_create           :generate_site
   before_save             :update_site
 
  def generate_site
    site_name=read_attribute(:name)
    self.site_id=Site.create_if_needed(site_name)
    if self.site_id.nil? || self.site.nil?
	  if self.site.nil?
		raise "Failure to generate site for analyzer."
	  else
		raise "Failure to generate site for analyzer." + site.errors().full_messages().join(',')
	  end
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

  def get_port_descr
    calc_port=get_calculated_port().to_s.rjust(3,'0')
    analyzer=switch.analyzer.ip
    template ="%s[%d]"
    return "#{analyzer} [#{calc_port}]"
  end

  def SwitchPort::inverse_port(calculated_port, port_count)
    address=(calculated_port/port_count).to_i+1
    port_nbr=(calculated_port%port_count)+1
    result= { 
      :address=>address,
      :port_nbr=>port_nbr
    }
    return result
    #switch_id & port number
  end

  def get_calculated_port
    if self.switch.nil?
      raise ("Switchport has no associated switch.")
    end
    if self.switch.master_switch_flag #This switch is a combiner
      return nil
    else #This is a secondary switch
      if switch.analyzer.nil?
        #Somehow analyzer got deleted.
        raise ("Switch #{self.switch.id} has no associated analyzer")
      elsif switch.analyzer.switches.first.master_switch_flag
        calculated_port=(switch.address-2) *switch.analyzer.port_count + port_nbr
      else
        calculated_port=(switch.address-1) *switch.analyzer.port_count + port_nbr
      end
    end
    return calculated_port
  end
  
  def SwitchPort.get_calculated_port(id)
    port=SwitchPort.find(id)
    if port.switch.nil?
      raise ("Switchport has no associated switch.")
    end
    if port.switch.master_switch_flag #This switch is a combiner
      return nil
    else #This is a secondary switch
      if port.switch.analyzer.nil?
        #Somehow analyzer got deleted.
        raise ("Switch #{self.switch.id} has no associated analyzer")
      elsif port.switch.analyzer.switches.first.master_switch_flag
        calculated_port=(port.switch.address-2) *port.switch.analyzer.port_count + port.port_nbr
      else
        calculated_port=(port.switch.address-1) *port.switch.analyzer.port_count + port.port_nbr
      end
    end
    return calculated_port
  end
  
  def get_site
    if site.nil? 
      sw=switch
      anl=sw.analyzer
      return anl.get_site
    end
    return site
  end
  def is_return_path?
    if !self.purpose.nil? && self.purpose.eql?(SwitchPort::RETURN_PATH)
      return true
    else
      return false
    end
  end
  def is_forward_path?
    if !self.purpose.nil? && self.purpose.eql?(SwitchPort::FORWARD_PATH)
      return true
    else
      return false
    end
  end
  def purpose_label
    if is_return_path?
      return "Return Path"
    elsif is_forward_path?
      return "Forward Path"
    else
      return "Maintenance"
    end
  end
  def has_alarm?
    if self.purpose == SwitchPort::RETURN_PATH && self.switch.analyzer.status == Analyzer::INGRESS
      if Alarm.find(:first, :conditions => ["site_id=? and active=1", self.site_id])
        return true
      else
        return false
      end
    end
    if self.purpose == SwitchPort::FORWARD_PATH && self.switch.analyzer.status == Analyzer::DOWNSTREAM
      if DownAlarm.find(:first,:conditions => ["site_id=? and active=1",self.site_id])
        return true
      else
        return false
      end
    end
    return false
  end
end
