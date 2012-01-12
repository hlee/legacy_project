class ConfigParam < ActiveRecord::Base
  validates_uniqueness_of   :name
  validates_inclusion_of    :ident, 		
														:in =>1..54
  validates_presence_of 		:val
  validates_inclusion_of 		:data_type, 
														:in=>1..4
  validates_numericality_of :size
  validates_length_of 			:descr, 
														:within => 10..255
  validates_inclusion_of 		:category, 
														:in=>['ANALYZER SETTING', 'CORPORATE', 'SNMP','REPORT', 'NETWORK', 'INSTALL', 'SMTP','ALARM FLOODING CONFIG'],
														:message => "must be one of "
  after_save                :update_smtp_settings
  after_save                :expire_cached_config

  @@cached_config={}
  IntType=1
  FloatType=2
  StringType=3
  Counter=4

  #Ident Parameters
  StartFreq=1
  StopFreq=2
  Company=3
  DashboardRecCount=4
  AnalyzerId=5
  HMID=6
  NetTimeout=7
  RetryCount=8
  MonitorStartPort=9
  MonitorStopPort=10
  ServerPath=11
  IptablesStartPort=12
  IptablesStopPort=13
  DefaultProfile=14
  EmailAddress=15
  SMTP_SERVER=17
  SMTP_PORT=18
  SMTP_USERNAME=20
  SMTP_PASSWORD=21
  SENDER_ADDRESS=22
  REPLY_ADDRESS=23
  SNMP_COUNTER=35
  DOWNSTREAM_DATA_SUMMARIZATION=36
  UPSTREAM_DATA_SUMMARIZATION=37
  INGRESS_ALARM_SUMMARIZATION=38
  DOWNSTREAM_ALARM_SUMMARIZATION=39
  LASER_CLIP_START=40
  LASER_CLIP_STOP=41
  ALARM_FLOOD_THRESHOLD=50
  CYCLE_COUNT=51
  FLOOD_RESTORE_CYCLE=52

  def ConfigParam.increment(name = "")
    if name.kind_of? Integer
      orig_name = name
      name = ConfigParam.find(:first, :conditions=>["ident=%d",name]).name
      ActiveSupport::Deprecation.warn(
        "You called ConfigParam.get_value(#{orig_name.inspect}) which is a deprecated API call. " +
        "Instead you should use ConfigParam.get_value('#{name}').  Passing the ConfigParam ident " +
        "as an integer instead of a String will be removed at a later date.", caller(2)
      )
    end
    param=ConfigParam.find_by_name(name)
    if param.nil?
      raise("ConfigParam #{name} is not a counter")
    end
    if param.data_type != Counter
      raise("ConfigParam #{name} is not a counter")
    end
    val=param.val.to_i
    val+=1
    param.update_attribute(:val,val.to_s)
    return val
  end
 
  def ConfigParam.get_value(name = "")
    verify_active_connections!
    if name.kind_of? Integer
      orig_name = name
      name = ConfigParam.find(:first, :conditions=>["ident=%d",name]).name
    end
    if (@@cached_config.key?(name))
      return @@cached_config[name]
    end
    if name.eql?('version')
      # The version info is stored in the VERSION file which is created
      # by the rpmbuild process.  Read it in, if it's not a valid version
      # number (file doesn't exist or is empty) then put in a default version
      # number.
      begin
        open('VERSION') do |file|
          file.each { |version|
            @@cached_config[name] = version.chomp
          }
        end
      rescue Errno::ENOENT
      end
      if @@cached_config[name].nil? || @@cached_config[name].eql?('')
        @@cached_config[name] = "999.999-999"
      end
      return @@cached_config[name]
    end
    if name.eql?('License')
      begin
        @@cached_config[name] = License.new('license.txt.asc')
      rescue Errno::ENOENT
      end
      if @@cached_config[name].nil? || @@cached_config[name].eql?('')
        @@cached_config[name] = "999.999-999"
      end
      return @@cached_config[name]
    end
    param=ConfigParam.find_by_name(name)
    if param.nil?
      raise("ConfigParam #{name} does not exist.")
    end
    multiplier=1
    if param.uom.eql?('Mhz')
      multiplier=1000000
    end
    if (param.data_type==IntType)
      @@cached_config[name]= param.val.to_i * multiplier
      return @@cached_config[name] 
    end
    if (param.data_type==FloatType)
      @@cached_config[name]= param.val.to_f * multiplier
      return @@cached_config[name]
    end
    if (param.data_type==StringType)
      @@cached_config[name]= param.val.to_s
      return @@cached_config[name]
    end
    if (param.data_type==Counter)
      @@cached_config[name]= param.val.to_i
      return @@cached_config[name]
    end
    raise("No type matched  #{param.data_type} for #{name}")
    return nil
  end
  def before_destroy
    raise 'You should not delete ConfigParams, it will cause bad things to happen.'
    return false
  end
	protected
  def expire_cached_config
    if (@@cached_config.key?(name))
      @@cached_config.delete(name)
    end
  end
  def update_smtp_settings
    if self.category.eql?('SMTP')
      case self.name
      when "SMTP Server"
        ActionMailer::Base.smtp_settings[:address] = self.val
      when "SMTP Port"
        puts "#{self.name} #{self.val}"
        ActionMailer::Base.smtp_settings[:port] = self.val
      when "SMTP Authentication"
        ActionMailer::Base.smtp_settings[:authentication] = self.val
      when "SMTP username"
        ActionMailer::Base.smtp_settings[:user_name] = self.val
      when "SMTP Password"
        ActionMailer::Base.smtp_settings[:password] = self.val
      end
    end
  end
	def validate
		if !uom.blank? && !['milliseconds', 'Mhz'].include?(uom)
			errors.add(:uom, "should be milliseconds, Mhz or blank")
		end
    if name.eql?("Email Address")
      unless val =~ /^[^@]+\@[^\.]+\.[^@]+$/
			  errors.add(:val, "Email address should be of the ______@_____.___ format")
      end
    end
    if name.eql?("Allow Anonymous")
      val.downcase!
      unless val =~ /^(yes|no)$/
			  errors.add(:val, "Allow Anonymous must be yes or no")
      end
    end
    if !val.blank? && data_type.to_i.eql?(1)
      unless val.to_s =~ /^\d+$/
			  errors.add(:val, "Parameter must be an integer, you provided #{val}")
      end
    end
    if !val.blank? && data_type.to_i.eql?(2)
      unless val.to_s =~ /^\d+\.?\d*$/ 
			  errors.add(:val, "Parameter must be an Float, you provided #{val}")
      end
    end
    if ident==1 || ident == 2
      stored=ConfigParam.find(id)
      dlcount=Datalog.count(:all)
      if (dlcount > 0) && (stored.val != val)
			  errors.add_to_base("Unable to change frequency range when Datalog has data.")
      end
      conn_analyzers=Analyzer.count(:conditions=>"status = 12")
      if (conn_analyzers > 0)
			  errors.add_to_base("Unable to change frequency range when Analyzers are in ingress monitoring mode")
      end
      start_freq=0
      stop_freq=0
      if ident==1
       stop_freq =ConfigParam.get_value(StopFreq).to_i/1000000
       start_freq = val.to_i
      end
      if id==24
       start_freq =ConfigParam.get_value(StartFreq).to_i/1000000
       stop_freq = val.to_i
      end
      if start_freq >= stop_freq
			  errors.add_to_base("Start Frequency must be less than Stop Frequency ")
      end
    end
	end
end
