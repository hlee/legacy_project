class AddAlarmEmailAddress < ActiveRecord::Migration
  def self.up
    add_column :alarms, :email, :string, :null => false
    add_column :down_alarms, :email, :string, :null => false
  end

  def self.down
    remove_column :alarms, :email
    remove_column :down_alarms, :email
  end
end
