class AddAlarmDuration < ActiveRecord::Migration
  def self.up
    add_column "alarms", "end_time", :datetime
    add_column "down_alarms", "end_time", :datetime
  end

  def self.down
    remove_column "alarms", "end_time"
    remove_column "down_alarms", "end_time"
  end
end
