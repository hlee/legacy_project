class AddFirmwarePtr < ActiveRecord::Migration
  def self.up
     add_column "analyzers", "firmware_ref", :string, :default=>''
  end
  def self.down
     remove_column "analyzers", "firmware_ref"
  end
end
