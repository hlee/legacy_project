class AddReasonPermission < ActiveRecord::Migration
  def self.up
    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "static_permissions,roles_static_permissions"
    Rake::Task["db:YAML:delete"].invoke
    Rake::Task["db:YAML:restore"].invoke
  end

  def self.down
  end
end
