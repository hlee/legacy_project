class AddProfileInfoToAlarm < ActiveRecord::Migration
  def self.up
    add_column "alarms", "major_offset", :float
    add_column "alarms", "minor_offset", :float
    add_column "alarms", "loss_offset", :float
    add_column "alarms", "link_loss", :boolean
    add_column "alarms", "trace", :binary
  end

  def self.down
    remove_column "alarms", "major_offset"
    remove_column "alarms", "minor_offset"
    remove_column "alarms", "loss_offset"
    remove_column "alarms", "link_loss"
    remove_column "alarms", "trace"
  end
end
