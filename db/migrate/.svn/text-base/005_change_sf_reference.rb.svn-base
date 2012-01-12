class ChangeSfReference < ActiveRecord::Migration
  def self.up
     rename_column "analyzers", "sf_system_file_id", "sf_test_plan_id"
  end

  def self.down
     rename_column "analyzers", "sf_test_plan_id", "sf_system_file_id"
  end
end
