class AddUniqueRegion < ActiveRecord::Migration
  def self.up
    change_column("regions", "name", :string,:null => false, :default => "South East USA" )
    change_column("regions", "ip", :string, :null => false, :default => "10.0.0.7")
    add_index(:regions,[:name],:unique=>true)
    add_index(:regions,[:ip],:unique=>true)
  end

  def self.down
    change_column("regions","name", :string, :default => "South East USA")
    change_column("regions","ip",:string, :default => "10.0.0.7")
    remove_index(:regions,:column=>:name)
    remove_index(:regions,:column=>:ip)
  end
end

