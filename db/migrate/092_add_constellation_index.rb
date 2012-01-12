class AddConstellationIndex < ActiveRecord::Migration
  def self.up
    add_index(:constellations,[:site_id,:freq,:dt],:unique=>true,:name =>"conste_idx") 
  end

  def self.down
    remove_index(:constellations,:name => "conste_idx")
  end
end
