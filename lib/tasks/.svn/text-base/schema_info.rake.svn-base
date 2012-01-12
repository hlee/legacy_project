namespace :db do
  desc "Returns the current schema version"
  task :version => :environment do
    versions = Array.new
    Dir.foreach('db/migrate') { |x| 
      if x =~ /(\d+)_.*\.rb$/
        versions << sprintf("%d", $1.to_i)
      end
    }
    begin
      versions = versions.uniq
      puts "Available versions: " + versions.sort{|x,y| x.to_i <=> y.to_i}.join(" ")
      puts "Current version: " + ActiveRecord::Migrator.current_version.to_s
    rescue
      puts 'Database has not been migrated yet.  Try rake db:migrate.'
    end
  end
  task :info => :environment do
    Rake::Task["db:version"].invoke
  end
end
