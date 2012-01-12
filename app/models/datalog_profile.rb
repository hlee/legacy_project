class DatalogProfile < ActiveRecord::Base
  attr_accessor :trigger_avg
  belongs_to :analyzer
  validates_uniqueness_of :name 
  validates_length_of     :name, :within => 1..25,
                          :too_long =>"please enter at most %d character",  
                          :too_short=>"please enter at least %d character"
  validates_numericality_of :bandwidth, :greater_than_or_equal_to => 1000, :allow_nil =>false, :only_integer => false, :less_than => 100000000
  validates_numericality_of :freq1, :greater_than_or_equal_to => 1000000, :allow_nil =>true, :only_integer => false, :less_than => 1500000001
  validates_numericality_of :freq2, :greater_than_or_equal_to => 1000000, :allow_nil =>true, :only_integer => false, :less_than => 1500000001
  validates_numericality_of :freq3, :greater_than_or_equal_to => 1000000, :allow_nil =>true, :only_integer => false, :less_than => 1500000001
  validates_numericality_of :freq4, :greater_than_or_equal_to => 1000000, :allow_nil =>true, :only_integer => false, :less_than => 1500000001
  validates_numericality_of :limit_val, :greater_than_or_equal_to => -50, :allow_nil =>false, :only_integer => false, :less_than => 100
  validates_presence_of   :analyzer_id,
                          :message=>"Analyzer not found." 
  validates_numericality_of :freq_count ,:greater_than => 0, :allow_nil=>false, :only_integer => true , :less_than=>5,:if =>" trigger_type == 2"

  before_save :gen_std_profile
  SAMPLE_COUNT=500
  validate :freq_range_test

  def freq_range_test
    start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
    stop_freq=ConfigParam.get_value(ConfigParam::StopFreq)
    if !(freq1.nil? || freq1 == "")
      if ((freq1-(bandwidth/2)-200000) <= start_freq)
         errors.add_to_base "Frequency 1 - (bandwidth/2) must be greater than #{(start_freq+200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
      if ((freq1+(bandwidth/2)+200000) >= stop_freq)
         errors.add_to_base "Frequency 1 + (bandwidth/2) must be less than #{(stop_freq-200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
    end
    if !(freq2.nil? || freq2 == "") 
      if ((freq2-(bandwidth/2)-200000) <= start_freq)
         errors.add_to_base "Frequency 2 - (bandwidth/2) must be greater than #{(start_freq+200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
      if ((freq2+(bandwidth/2)+200000) >= stop_freq)
         errors.add_to_base "Frequency 2 + (bandwidth/2) must be less than #{(stop_freq-200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
    end
    if !(freq3.nil? || freq3 == "")
      if ((freq3-(bandwidth/2)-200000) <= start_freq)
         errors.add_to_base "Frequency 3 - (bandwidth/2) must be greater than #{(start_freq+200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
      if ((freq3+(bandwidth/2)+200000) >= stop_freq)
         errors.add_to_base "Frequency 3 + (bandwidth/2) must be less than #{(stop_freq-200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
    end
    if !(freq4.nil? || freq4 == "")
      if ((freq4-(bandwidth/2)-200000) <= start_freq)
         errors.add_to_base "Frequency 4 - (bandwidth/2) must be greater than #{(start_freq+200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
      if ((freq4+(bandwidth/2)+200000) >= stop_freq)
         errors.add_to_base "Frequency 4 + (bandwidth/2) must be less than #{(stop_freq-200000)/1000000 } MHz (We need a 200 Khz buffer from the edge)"
      end
    end
  end

  #validate :freq_count_conditional_test

  #def freq_count_conditional_test
  # if (trigger_type==1) #Freq Count must be blank
  #   if (!freq_count.blank? && freq_count.to_i != 4)
  #      errors.add(:freq_count, ": Average alarm type must operate across all 4 frequencies.")
  #   end
  # end
  #end
  def draw_trace
    trace=[]
    start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
    stop_freq=ConfigParam.get_value(ConfigParam::StopFreq)
    freq_delta=(stop_freq-start_freq)/(SAMPLE_COUNT-1)
    0.upto(SAMPLE_COUNT-1) {|idx| trace[idx]=60}
    offset_idx=(bandwidth/2)/freq_delta
    if !(freq1.nil? || freq1 == "")
      idx1=(freq1-start_freq)/freq_delta
      (idx1-offset_idx).floor().upto((idx1+offset_idx).ceil()) { |idx| trace[idx]=limit_val}
    end
    if !(freq2.nil? || freq2 == "")
      idx2=(freq2-start_freq)/freq_delta
      (idx2-offset_idx).floor().upto((idx2+offset_idx).ceil()) { |idx| trace[idx]=limit_val}
    end
    if !(freq3.nil? || freq3 == "")
      idx3=(freq3-start_freq)/freq_delta
      (idx3-offset_idx).floor().upto((idx3+offset_idx).ceil()) { |idx| trace[idx]=limit_val}
    end
    if !(freq4.nil? || freq4 == "")
      idx4=(freq4-start_freq)/freq_delta
      (idx4-offset_idx).floor().upto((idx4+offset_idx).ceil()) { |idx| trace[idx]=limit_val}
    end
    return trace
  end
  def gen_std_profile
    @freq_num = 0
    @freq_num = @freq_num + 1 if !(freq1.nil? || freq1 == "")
    @freq_num = @freq_num + 1 if !(freq2.nil? || freq2 == "")
    @freq_num = @freq_num + 1 if !(freq3.nil? || freq3 == "")
    @freq_num = @freq_num + 1 if !(freq4.nil? || freq4 == "")
    if @freq_num == 0
      errors.add("freq1_disp", "At least one frequency must be input")
      return false
    end
        if trigger_type == 1
          write_attribute(:freq_count,@freq_num)
        end
    if trigger_type == 2
      if freq_count > @freq_num
        errors.add("freq_count", "should be no more than the number of Frequences")
        return false
      end
    end

    if (profile_id.nil?)
      prof=Profile.new()
    else
      prof=Profile.find(profile_id)
      if (prof.nil?)
        prof=Profile.new()
      end
    end
    vals=[]
    freqs=[]
    start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
    stop_freq=ConfigParam.get_value(ConfigParam::StopFreq)
    if !(freq1.nil? || freq1 == "")
      freqs.push(freq1-(bandwidth/2) - 200000) #Go 200 Khz before the range
      freqs.push(freq1-(bandwidth/2))
      freqs.push(freq1+(bandwidth/2))
      freqs.push(freq1+(bandwidth/2) + 200000) #Go 200 Khz beyond the range
    end
    if !(freq2.nil? || freq2 == "")
      freqs.push(freq2-(bandwidth/2) - 200000) #Go 200 Khz before the range
      freqs.push(freq2-(bandwidth/2))
      freqs.push(freq2+(bandwidth/2))
      freqs.push(freq2+(bandwidth/2) + 200000)
    end
    if !(freq3.nil? || freq3 == "")
      freqs.push(freq3-(bandwidth/2) - 200000)
      freqs.push(freq3-(bandwidth/2))
      freqs.push(freq3+(bandwidth/2))
      freqs.push(freq3+(bandwidth/2) + 200000)
    end
    if !(freq4.nil? || freq4 == "")
      freqs.push(freq4-(bandwidth/2) - 200000)
      freqs.push(freq4-(bandwidth/2))
      freqs.push(freq4+(bandwidth/2))
      freqs.push(freq4+(bandwidth/2) + 200000)
    end
    vals=[50,limit_val, limit_val,50]*@freq_num
    prof.name="DLPROF_"+name
    prof.trace=Profile.build_trace(vals,freqs)
    puts prof.trace.inspect()
    prof.major_offset=0
    prof.minor_offset=0
    prof.loss_offset=-50
    unless(prof.save())
      return false
    end
    self.profile_id=prof.id
  end
  def datalog_descr
    if (datalog_trace == 1)
      return "Max. Trace"
    elsif (datalog_trace == 2)
      return "Avg. Trace"
    elsif (datalog_trace == 3)
      return "Min. Trace"
    end
    return ""
  end
  def trigger_type_descr
    if trigger_type == 2
      return "Max level of #{freq_count} of 4 frequency slots must be greather than limit"
    elsif trigger_type == 1
      return "Average of the four frequencies must be above limit"
    end
    return ""
  end
  def bandwidth_disp=(x)
     write_attribute(:bandwidth,(x.to_f*1_000).to_i)
  end
  def bandwidth_disp()
    if bandwidth.nil?
      return nil
    else
      return read_attribute(:bandwidth)/1_000.0
    end
  end
  def freq1_disp=(x)
    if x.nil? || x == ""
      write_attribute(:freq1,nil)
    else
      write_attribute(:freq1,(x.to_f*1_000_000).to_i)
    end
  end
  def freq1_disp()
    if freq1.nil?
      return nil
    else
      return read_attribute(:freq1)/1000000.0
    end
  end
  def freq2_disp=(x)
    if x.nil? || x == ""
      write_attribute(:freq2,nil)
    else
      write_attribute(:freq2,(x.to_f*1_000_000).to_i)
    end
  end
  def freq2_disp()
    if freq2.nil?
      return nil
    else
      return read_attribute(:freq2)/1000000.0
    end
  end
  def freq3_disp=(x)
    if x.nil? || x == ""
      write_attribute(:freq3,nil)
    else
      write_attribute(:freq3,(x.to_f*1_000_000).to_i)
    end
  end
  def freq3_disp()
    if freq3.nil?
      return nil
    else
      return read_attribute(:freq3)/1000000.0
    end
  end
  def freq4_disp=(x)
    if x.nil? || x == ""
      write_attribute(:freq4,nil)
    else
      write_attribute(:freq4,(x.to_f*1_000_000).to_i)
    end
  end
  def freq4_disp()
    if freq4.nil?
      return nil
    else
      return read_attribute(:freq4)/1000000.0
    end
  end
  def max_within_bwd(image,datalog,freq)
   if freq.nil? || freq ==""
     return 0
   end
   cell_bwd=(datalog.stop_freq-datalog.start_freq)/image.length
   cell_half_count=((bandwidth/cell_bwd)/2.0).floor()
   cell_position=((freq-datalog.start_freq)/cell_bwd)
   max_val=nil
   image[(cell_position-cell_half_count)..(cell_position+cell_half_count)].each { |val|
     if (max_val.nil?) || (max_val < val)
       max_val=val
     end
   }
   return max_val
  end
  
  
  def test_trace(datalog)
   test_image=[]
    logger.debug "Which Image?"
    if (datalog_trace==1)
      logger.debug "Using max Image"
      test_image=datalog.max_image
    elsif (datalog_trace==2)
      logger.debug "using avg image"
      test_image=datalog.image
    elsif (datalog_trace==3)
      logger.debug " using min_image image"
      test_image=datalog.min_image
    end
    max1=max_within_bwd(test_image,datalog,freq1)
    max2=max_within_bwd(test_image,datalog,freq2)
    max3=max_within_bwd(test_image,datalog,freq3)
    max4=max_within_bwd(test_image,datalog,freq4)
    over_limit_count=0
    if (trigger_type == 1)
      @trigger_avg=(max1+max2+max3+max4)/freq_count
      logger.debug "Do I Got an alarm? #{@trigger_avg} < #{limit_val}"
      if @trigger_avg > limit_val
        return true
      end
    end
    if (trigger_type ==2) #Max trigger type
      if (max1 > limit_val)
         over_limit_count=over_limit_count+1
      end
      if (max2 > limit_val)
         over_limit_count=over_limit_count+1
      end
      if (max3 > limit_val)
         over_limit_count=over_limit_count+1
      end
      if (max4 > limit_val)
         over_limit_count=over_limit_count+1
      end
      logger.debug "Do I Got an alarm #{over_limit_count} >- #{freq_count}"
      if (over_limit_count >= freq_count)
         return true #Alarm Triggered
      end
    end
      logger.debug "No Alarms"
    return false
  end

  def DatalogProfile::test_trace_set(datalog)
    logger.debug "Test Trace Set"
    site=datalog.site
    #breakpoint
    if site.nil?
      return false
    end
    anl=site.analyzer
    if anl.nil?
      return false
    end
    logger.debug datalog.inspect()
    dlps=anl.datalog_profiles.each { |dlp|
      if dlp.test_trace(datalog)
        span=anl.stop_freq-anl.start_freq
        center_freq=anl.start_freq + (span/2)
        alarm_type=(dlp.trigger_type == 1 ? 11 : 10)
        alarm=Alarm.generate(
          :profile_id             => dlp.profile_id,
          :site_id                => site.id,
          :monitoring_mode        => 3,
          :calibration_status     => 1,
          :event_time             => DateTime.now(),
          :event_time_hundreths   => 30,
          :alarm_level            => 0,
          :external_temp          => 53,
          :center_frequency       => center_freq,
          :span                   => span,
          :email                  => anl.email, 
          :loss_offset            => @trigger_avg, #Reuse loss offset to store average.
          :alarm_type             => alarm_type)
        if (dlp.datalog_trace==1)
          alarm.image=datalog.max_image
        elsif (dlp.datalog_trace==2)
          alarm.image=datalog.image
        elsif (dlp.datalog_trace==3)
          alarm.image=datalog.min_image
        else
          alarm.image=nil
        end
        alarm.save()
      end
    }
     
  end
end
