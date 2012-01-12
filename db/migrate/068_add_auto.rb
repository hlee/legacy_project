class AddAuto < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :auto_mode, :int, :default => 3
	add_column :analyzers, :att_count, :int, :default => 999
	add_column :analyzers, :reb_count, :int
	
	Analyzer.find(:all).each { |a|
      a.auto_mode=3
	  a.att_count=999
      a.save
    }
  end
  
  def self.down
    remove_column :analyzers, :auto_mode
	remove_column :analyzers, :att_count
	remove_column :analyzers, :reb_count
  end
end