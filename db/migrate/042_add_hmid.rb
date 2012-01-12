class AddHmid < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :hmid, :integer , :null => false, :default=>1
  end

  def self.down
    remove_column :analyzers, :hmid
  end
end
