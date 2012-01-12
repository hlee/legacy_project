class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name,      :default => "South East USA"
      t.string :ip,        :default => "10.0.0.7"
    end
    default_region=Region.new()
    default_region.name="DEFAULT"
    default_region.ip="127.0.0.1"
    default_region.id=1;
    default_region.save()
  end

  def self.down
    Region.delete_all
    drop_table :regions
  end
end
