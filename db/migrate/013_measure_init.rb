class MeasureInit < ActiveRecord::Migration
  def self.up
    add_column "measures", "divisor", :float
    add_column "measures", "measure_label", :string
    # Moved to migration 28 --JN
    #require 'rake'
    #rake = Rake::Application.new
    #ENV['FIXTURES'] = "measures"
    #Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
    remove_column "measures", "divisor"
    remove_column "measures", "measure_label"
  end
end
