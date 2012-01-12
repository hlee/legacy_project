class AddSweepTimeToAnalyzer < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :sweep_time, :integer, :default=>20
  end

  def self.down
    remove_column :analyzers, :sweep_time
  end
end
