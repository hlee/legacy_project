class LoadLicense < ActiveRecord::Migration
  def self.up
    ConfigParam.delete_all
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "config_params"
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
  end
end
