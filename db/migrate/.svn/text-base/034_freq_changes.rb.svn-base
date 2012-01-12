class FreqChanges < ActiveRecord::Migration
  def self.up
    change_column("channels", "channel_freq", :float )
    add_index(:channels,[:channel_freq], :unique=>true)
  end

  def self.down
    remove_index(:channels,:column=>:channel_freq)
  end
end
