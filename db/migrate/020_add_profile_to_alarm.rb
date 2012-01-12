class AddProfileToAlarm < ActiveRecord::Migration
  def self.up
		add_column "alarms", "profile_id", :integer
  end

  def self.down
		remove_column "alarms", "profile_id"
  end
end
