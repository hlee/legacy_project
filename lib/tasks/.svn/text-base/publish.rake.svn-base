PUBLISH_DIR = '/var/www/railsdoc'

desc 'Task to Publish documentation to server'
task 'doc:publish' => 'doc:app' do
   rm_rf(PUBLISH_DIR)
   cp_r('doc',PUBLISH_DIR)
   puts "publish" 
end


