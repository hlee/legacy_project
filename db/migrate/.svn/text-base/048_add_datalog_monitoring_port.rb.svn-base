class AddDatalogMonitoringPort < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :datalog_port, :string , :null => false, :default=>"3201"
    add_column :analyzers, :monitoring_port, :string , :null => false, :default=>"3001"
  end

  def self.down
    remove_column :analyzers, :datalog_port
    remove_column :analyzers, :monitoring_port
  end
end
