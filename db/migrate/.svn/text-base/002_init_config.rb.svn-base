class InitConfig < ActiveRecord::Migration
  def self.up
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "config_params"
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
    ConfigParam.delete_all()
  end
end
