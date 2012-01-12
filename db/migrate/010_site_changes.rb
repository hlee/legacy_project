class SiteChanges < ActiveRecord::Migration
  def self.up
     add_column "analyzers", "site_id", :integer
     add_column "sites", "sf_test_plan_id", :integer
     remove_column "analyzers", "sf_test_plan_id"
  end

  def self.down
     remove_column "analyzers", "site_id"
     remove_column "sites", "sf_test_plan_id"
     add_column "analyzers", "sf_test_plan_id", :integer
  end
end
