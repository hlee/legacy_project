class CreateSnapshots < ActiveRecord::Migration
  def self.up
    create_table :snapshots do |t|
	t.column "image",	:binary
    	t.column "site_id",	:integer
    	t.column "description",	:text
        t.column "session", :string
        t.column "create_dt", :datetime
        t.column "source", :string
        t.column "noise_floor", :float
        t.column "baseline", :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :snapshots
  end
end
