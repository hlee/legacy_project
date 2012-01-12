class AddDefaultProfile < ActiveRecord::Migration
  def self.up
    add_column "analyzers", "profile_id", :integer
    ConfigParam.delete_all
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "profiles,config_params"
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
    ConfigParam.delete_all
    Profile.delete_all
    remove_column "analyzers", "profile_id"
  end
end
