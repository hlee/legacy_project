class ModifyMeasureFreq < ActiveRecord::Migration
  def self.up
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "measures"
    Rake::Task["db:YAML:delete"].invoke
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
  end
end
