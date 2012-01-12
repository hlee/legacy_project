class CreateDatalogProfiles < ActiveRecord::Migration
  def self.up
    create_table :datalog_profiles do |t|
      t.integer :analyzer_id
      t.string :name
      t.integer :freq1
      t.integer :freq2
      t.integer :freq3
      t.integer :freq4
      t.integer :datalog_trace
      t.integer :bandwidth
      t.float :limit_val
      t.integer :freq_count
      t.integer :trigger_type

      t.timestamps
    end
  end

  def self.down
    drop_table :datalog_profiles
  end
end
