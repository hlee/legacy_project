class AddExceptionMsg < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :exception_msg, :string , :null => false, :default=>""
  end

  def self.down
    remove_column :analyzers, :exception_msg
  end
end
