namespace :db do
  namespace :table do
    desc "Deletes all data from the channels, alarms, down_alarms, measurements and datalogs table"
    task :purge => :environment do
      %w{channels alarms down_alarms measurements datalogs}.each { |table|
        table = Inflector.pluralize(table) if ActiveRecord::Base.pluralize_table_names
        puts "TRUNCATE #{table}"
        ActiveRecord::Base.connection.execute "TRUNCATE #{session_table}"
      }
    end
  end
end
