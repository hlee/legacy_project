class AddChannelFreq < ActiveRecord::Migration
  def self.up
		add_column "channels", "channel_freq",:float
  end

  def self.down
		remove_column "channels", "channel_freq"
  end
end
