class ChangeChannelNbr < ActiveRecord::Migration
  def self.up
    change_column "channels", "channel",:string, :length=>3


  end

  def self.down
    change_column "channels", "channel",:integer
  end
end
