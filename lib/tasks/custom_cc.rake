 desc 'Custom cruise task for Realworx'  
 task :cruise  do  
    ENV['RAILS_ENV']='test'
    Rake::Task["setupdb"].invoke()
    Rake::Task["db:migrate"].invoke()
    Rake::Task["test"].invoke()
  end
 task :setupdb do
    require 'fileutils'
   
    if !File.exists?(Dir.pwd + "/config/database.yml")
       FileUtils.cp(Dir.pwd + "/config/database.yml.sample",Dir.pwd + "/config/database.yml")  
    end
 end  
