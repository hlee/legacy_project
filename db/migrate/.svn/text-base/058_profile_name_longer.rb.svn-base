class ProfileNameLonger < ActiveRecord::Migration
  def self.up
    change_column "profiles", "name", :string, :length => 50
  end

  def self.down
    change_column "profiles", "name", :string, :length => 9
  end
end
