class Channel < ActiveRecord::Base
  has_many :measurements
  has_many :down_alarms

  def Channel.get_chan_id(site_id,frequency, channel_type, modulation,channel="UNKNOWN")
    ch=Channel.find(:first, :conditions =>['site_id=? and channel_freq>=? and channel_freq <= ? and channel_type = ? and modulation = ?',site_id,frequency-1000,frequency+1000,channel_type.to_s,modulation])
    if ch.nil?
      frequency_str=((frequency.to_i/1_000).to_f/1_000).to_s + " MHz"
      ch=Channel.create(:channel_freq=>frequency, :channel_name=>frequency_str, :site_id=>site_id, :channel_type => channel_type.to_s, :modulation=> modulation, :channel => channel)
    end
    return ch.id
  end
end
