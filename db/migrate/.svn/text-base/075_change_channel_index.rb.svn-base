class ChangeChannelIndex < ActiveRecord::Migration
  def self.up
    add_index(:channels,["site_id","channel_freq","modulation"], :unique => true)
    remove_index(:channels,"channel_freq")
  end

  def self.down
    remove_index(:channels,["site_id","channel_freq","modulation"])
    add_index(:channels,[:channel_freq], :unique=>true)
  end
end
