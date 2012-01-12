class AddUol < ActiveRecord::Migration
  def self.up
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "config_params"
    Rake::Task["db:YAML:delete"].invoke
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
  end
end
