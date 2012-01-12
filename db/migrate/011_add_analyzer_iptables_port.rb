class AddAnalyzerIptablesPort < ActiveRecord::Migration
  def self.up
     add_column "analyzers", "iptables_port", :string, {:limit => '5', :default=>'unk', :null => false}
  end

  def self.down
     remove_column "analyzers", "iptables_port"
  end
end
