class InitMeasure < ActiveRecord::Migration
  def self.up
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "measures"
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
    Measure.delete_all()
  end
end