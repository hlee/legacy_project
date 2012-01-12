class AddSnmpFlag < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :snmp_active, :boolean 
    add_column :switch_ports, :purpose, :integer
    add_column :switch_ports, "sf_test_plan_id", :integer
  end

  def self.down
    remove_column :analyzers, :snmp_active
    remove_column :switch_ports, :purpose
    remove_column :switch_ports, "sf_test_plan_id"
  end
end
