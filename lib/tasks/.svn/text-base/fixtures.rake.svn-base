namespace :db do
  namespace :YAML do
    desc 'Create YAML backup fixtures'
    task :backup => :environment do
      sql = "SELECT * FROM %s" 
      skip_tables = ["schema_info", "sessions"]
      ActiveRecord::Base.establish_connection
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      tables.each do |table_name|
        i = "000" 
        File.open("#{RAILS_ROOT}/db/fixtures/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end

    desc "Load db/fixtures in fixtures_load_order" 
    task :restore => :environment do
      class Rake::Task
        attr_accessor :already_invoked
      end
      Rake::Task["db:YAML:restore"].already_invoked = false
      ActiveRecord::Base.establish_connection
      require 'active_record/fixtures'
      skip_tables = ["schema_info", "sessions"]
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      Fixtures.create_fixtures("#{RAILS_ROOT}/db/fixtures", tables)
      puts "Loaded these fixtures: " + tables.collect { |f| f.to_s }.join(', ')
    end
  
    desc "Deletes all fixture tables mentioned in FIXTURES environment in reverse order to avoid constraint problems"
    task :delete => :environment do
      class Rake::Task
        attr_accessor :already_invoked
      end
      Rake::Task["db:YAML:restore"].already_invoked = false
      ActiveRecord::Base.establish_connection
      puts "#{ENV['FIXTURES']}"
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
      tables.reverse.each do |fixture_name|
        puts "...#{fixture_name}..."
      end
      tables.reverse.each do |fixture_name|
          puts "Deleting from #{fixture_name} #{tables.join(' ')}"
          ActiveRecord::Base.connection.update "DELETE FROM #{fixture_name}"
      end
    end
  end
end
