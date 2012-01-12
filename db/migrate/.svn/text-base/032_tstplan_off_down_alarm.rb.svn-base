class TstplanOffDownAlarm < ActiveRecord::Migration
  def self.up
    remove_column "down_alarms", "sf_test_plan_id"
  end

  def self.down
    add_column "down_alarms", "sf_test_plan_id", :integer
  end
end
