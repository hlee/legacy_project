class AddWebApiUrl < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :api_url, :string,  :null => true
  end

  def self.down
    remove_column :analyzers, :api_url
  end
end
