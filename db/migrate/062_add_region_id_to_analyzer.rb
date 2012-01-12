class AddRegionIdToAnalyzer < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :region_id, :integer,:default => 1
    Analyzer.find(:all).each { |a|
      a.region_id=1
      a.save
    }
  end

  def self.down
    remove_column :analyzers, :region_id
  end
end
