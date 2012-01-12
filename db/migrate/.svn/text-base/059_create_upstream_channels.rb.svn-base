class CreateUpstreamChannels < ActiveRecord::Migration
  def self.up
    create_table :upstream_channels do |t|
      t.string :name
      t.integer :freq
      t.integer :bandwidth

      t.timestamps
    end
  end

  def self.down
    drop_table :upstream_channels
  end
end
