class FixSystemFileRef < ActiveRecord::Migration
  def self.up
     rename_column "sf_test_plans", "system_file_id", "sf_system_file_id"
  end

  def self.down
     rename_column "sf_test_plans", "sf_system_file_id", "system_file_id"
  end
end
