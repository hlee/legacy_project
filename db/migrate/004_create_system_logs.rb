class CreateSystemLogs < ActiveRecord::Migration
  def self.up
    create_table :system_logs do |t|
    t.column "short_descr",         :string,  :default => "NO DESCRIPTION",   :null => false
    t.column "descr",               :text, :null => false
    t.column "analyzer_id",         :integer, :default => -1
    t.column "ts",                  :datetime
    t.column "level",               :integer, :null => false
    end
  end

  def self.down
    drop_table :system_logs
  end
end
