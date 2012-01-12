class CreateConstellations < ActiveRecord::Migration
  def self.up
    create_table :constellations do |t|
      t.column :site_id,      :integer
      t.column :image_data,   :binary,  {:limit => 2.kilobytes}
      t.column :dt,           :datetime
    end
  end

  def self.down
    Constellation.delete_all
    drop_table :constellations
  end
end
