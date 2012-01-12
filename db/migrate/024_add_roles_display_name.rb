class AddRolesDisplayName < ActiveRecord::Migration
  def self.up
    add_column "roles", "display_name", :string
  end

  def self.down
    remove_column "roles", "display_name"
  end
end
