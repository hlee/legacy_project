class ModifyFreqToChannels < ActiveRecord::Migration
  def self.up
	change_column "channels", "channel_freq",  :double
  end

  def self.down
	change_column "channels", "channel_freq",  :float
  end
end
