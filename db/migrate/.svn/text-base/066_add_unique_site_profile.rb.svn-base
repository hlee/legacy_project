class AddUniqueSiteProfile < ActiveRecord::Migration
  def self.up
    change_column("sites", "name", :string,:null => false )
    change_column("profiles", "name", :string,:length =>50, :null => false)
    add_index(:sites,[:name],:unique=>true)
    add_index(:profiles,[:name],:unique=>true)
  end

  def self.down
    change_column("sites","name",:string)
    change_column("profiles","name", :string, :length => 50)
    remove_index(:sites,:column=>:name)
    remove_index(:profiles,:column=>:name)
  end
end
