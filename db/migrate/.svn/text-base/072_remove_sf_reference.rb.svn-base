class RemoveSfReference < ActiveRecord::Migration
  def self.up
     remove_column "analyzers", "sf_test_plan_id"
     remove_column "switch_ports", "sf_test_plan_id"
  end

  def self.down
     add_column "analyzers", "sf_test_plan_id", :integer
     add_column "switch_ports", "sf_test_plan_id", :integer
  end
end
