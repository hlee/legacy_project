class AddAnalyzerEmail < ActiveRecord::Migration
  def self.up
     add_column "analyzers", "email", :string, {:default=>'', :null => false}
  end

  def self.down
     remove_column "analyzers", "email"
  end
end
