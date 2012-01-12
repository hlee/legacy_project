class DatalogProfileLinkProfile < ActiveRecord::Migration
  def self.up
    add_column :datalog_profiles, :profile_id , :integer
    add_column :alarms, :alarm_name , :string
  end

  def self.down
    remove_column datalog_profiles, :profile_id
    remove_column alarms, :alarm_name
  end
end
