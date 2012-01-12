class AddAnalyzerProcessingField < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :processing, :timestamp
  end

  def self.down
    remove_column :analyzers, :processing
  end
end
