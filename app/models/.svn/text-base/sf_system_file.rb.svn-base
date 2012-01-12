class SfSystemFile < ActiveRecord::Base
  has_many :sf_channels,:dependent=>:destroy
  has_many :sf_setups,:dependent=>:destroy
  has_many :sf_simple_channels,:dependent=>:destroy
  has_many :sf_test_plans,:dependent=>:destroy
  validates_format_of     :system_name,
                          :with => /\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i	

  Analog=0
  Digital=1

  def find_ch_by_freq(searchfreq)
    logger.error "Checking Channels,"
    channels=self.sf_channels
    channels.each { |ch|
      freq=nil
      if ch.channel_type.to_i == Analog
        freq=ch.channel_dtls["videofreq"]
      elsif ch.channel_type.to_i == Digital
        freq=ch.channel_dtls["centerfreq"]
      end
      #Just in case lets try to get the frequency again ignoring channel type.
      if freq.nil?
        if ch.channel_dtls.has_key?("videofreq")
          freq=ch.channel_dtls["videofreq"]
        elsif ch.channel_dtls.has_key?("centerfreq")
          freq=ch.channel_dtls["centerfreq"]
        end
      end
      logger.debug "Looking for freq: #{freq.to_i} ? #{searchfreq.to_i}"
      if searchfreq.to_i==freq.to_i
        logger.debug "Found #{searchfreq.to_i} == #{freq}"
        return ch
      end
    }
    return nil
  end
end
