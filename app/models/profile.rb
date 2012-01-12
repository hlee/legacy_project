class Profile < ActiveRecord::Base
  validates_uniqueness_of   :name
  validates_presence_of     :name,
                            :message=>"Please input a profile name."
  validates_format_of     :name,
                          :with => /\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i
  has_many :switch_ports
  before_validation :archive
  before_destroy :destroy_validate
  SAMPLE_COUNT=500
  DEFAULT_VAL=50 #If the drawn profile does not start at 50MHz or end at 450MHz
                 #Then we map it with this default value.
  extend ImageFunctions
  include ImageFunctions
  def archive
    return unless self.new_record?
    profile = Profile.find_by_name(self.name)
    unless profile.nil?
      profile.name = sprintf("a-%s", profile.id)
      profile.status = true
      unless profile.save 
        return false
      end
    end
  end
  def trace=(data)
    write_image(:trace, data)
  end
  def trace(start_freq=nil,stop_freq=nil)
    if start_freq.nil?
       return read_image(:trace)
    else
      cfg_start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
      cfg_stop_freq=ConfigParam.get_value(ConfigParam::StopFreq)
      return Profile.map_data(cfg_start_freq,cfg_stop_freq,start_freq,stop_freq,read_image(:trace),500)
    end
  end
  def Profile::build_trace(trace_vals,trace_freqs)
    built_image=[]
    start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
    stop_freq=ConfigParam.get_value(ConfigParam::StopFreq)
    freq_delta=(stop_freq-start_freq)/(SAMPLE_COUNT-1)
    start_diff=trace_freqs.min-start_freq
    stop_diff=trace_freqs.max-start_freq
    if (trace_vals.length != trace_freqs.length)
      raise "Freq array does not agree with Val array #{trace_vals.length},#{trace_freqs.length}"
    end
    if (start_diff <0)
      raise "Start Freq is <0 MHz #{start_diff}"
    end
    if (trace_freqs.max > stop_freq)
      raise "Stop Freq is #{trace_freqs.max} > #{stop_freq}"
    end
    trace_idx=1
    SAMPLE_COUNT.times { |idx|
      curr_freq=start_freq + idx * freq_delta
      if curr_freq < trace_freqs[0]
        built_image[idx]=DEFAULT_VAL
      elsif curr_freq > trace_freqs[-1]
        built_image[idx]=DEFAULT_VAL
      else
        while (trace_freqs[trace_idx] < curr_freq)
          trace_idx+=1
        end
        pct_divisor=(trace_freqs[trace_idx]-trace_freqs[trace_idx-1]).to_f
        pct_neumerator=(curr_freq-trace_freqs[trace_idx-1]).to_f
        pct=pct_neumerator/pct_divisor
        val=(trace_vals[trace_idx]-trace_vals[trace_idx-1])*pct+trace_vals[trace_idx-1]
        built_image[idx]=val
      end
    }
    raise "Illegal image size #{built_image.length}" if built_image.length!=500
    return built_image
  end
  def Profile::find_active_profiles
    list=Profile.find(:all).collect{|x|x.id}-DatalogProfile.find(:all).collect{|x|x.profile_id}
    return Profile.find(:all, :conditions => ["status is NULL and id in (?)",list])
  end
  def validate
    errors.add(:major_offset, "must be >= Minor Offset") unless major_offset >= minor_offset
    errors.add(:minor_offset, "must be <= Major Offset") unless minor_offset <= major_offset
    if Analyzer.count(:conditions => ["profile_id = ? and status= ?", self.id, Analyzer::INGRESS]) > 0
      errors.add_to_base("One or more Analyzers are in Ingress Monitoring mode and use this profile.  Edits are disabled until you stop Ingress Monitoring.")
      return false
    end
    Analyzer.find(:all, :conditions => ["status = ?", Analyzer::INGRESS]).each { |analyzer|
      analyzer.switches.each { |switch|
        if switch.ingress_ports.count(:conditions => ["profile_id = ?", self.id]) > 0
          errors.add_to_base("One or more Analyzers are in Ingress Monitoring mode and use this profile.  Edits are disabled until you stop Ingress Monitoring on #{analyzer.name}.")
          return false
        end
      }
    }
  end
  def destroy_validate
    if Analyzer.count(:conditions => ["profile_id = ? ", self.id]) > 0
      errors.add_to_base("One or more Analyzers use this profile, Delete are disabled.")
      return false
    end
	if SwitchPort.exists?(:profile_id=> self.id)
	  errors.add_to_base("One or more Analyzers use this profile, Delete are disabled.")
      return false
	end
  end
  def short_name
    if name.length < 13
      return name
    else
      return "..." + name.slice(-10,10)
    end
  end
end
