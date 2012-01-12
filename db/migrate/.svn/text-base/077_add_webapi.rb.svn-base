class AddWebapi < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :webapi, :int, :default => 0
	
	Analyzer.find(:all).each { |a|
      a.webapi=0
      a.save
    }
  end
  
  def self.down
    remove_column :analyzers, :webapi
  end
end