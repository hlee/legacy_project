class LimitToMeasurement < ActiveRecord::Migration
  def self.up
    add_column "measurements", "min_limit", :float
    add_column "measurements", "max_limit", :float
    add_column "measurements", "tolerance", :float
    add_column "analyzers", "sf_test_plan_id", :integer
    remove_column "sites", "sf_test_plan_id"
  end

  def self.down
    remove_column "measurements", "min_limit"
    remove_column "measurements", "max_limit"
    remove_column "measurements", "tolerance"
    add_column "sites", "sf_test_plan_id", :integer
    remove_column "analyzers", "sf_test_plan_id"
  end
end
