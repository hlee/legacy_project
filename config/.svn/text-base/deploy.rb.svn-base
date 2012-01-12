set :stages, %w(verizon videotron buildbot waco test_qa)
set :application, "realworx-rails"
set :repository,  "svn://10.0.0.33/#{application}/tags/REALWORX_RELEASE_0-1-0/"
require 'capistrano/ext/multistage'
require 'erb'

set :application, "realworx-rails"
set :repository,  "https://gluttony/svn/realworx-rails/trunk"

before "deploy", "stop_master"
after "deploy", "start_master"

before "deploy:rollback", "stop_master"
after "deploy:rollback", "start_master"

before "deploy:setup", :db
after "deploy:update_code", "db:symlink"

namespace :db do
  desc "Create database yaml in shared path"
  task :default do
    # Didn't use socket in the base section below
    #socket: /tmp/mysql.sock
    db_config = ERB.new <<-EOF
development:
  database: #{dev_database}
  username: #{dev_db_user}
  password: #{dev_db_password}
  socket: #{socket}
  adapter: mysql

test:
  database: #{test_database}
  username: #{test_db_user}
  password: #{test_db_password}
  socket: #{socket}
  adapter: mysql

production:
  database: #{production_database}
  username: #{production_db_user}
  password: #{production_db_password}
  socket: #{socket}
  adapter: mysql
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config.result, "#{shared_path}/config/database.yml"
  end

  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "chown -R #{runner}:#{runner} #{release_path}"
  end
end

task :stop_master, :roles => :app do
  run "cd #{previous_release} && lib/daemons/master_ctl stop" if fetch(:restart_daemons, true)
  run "/etc/init.d/lighttpd stop" if fetch(:restart_lighttpd, true)
  run "/usr/bin/mongrel_cluster_ctl stop" if fetch(:restart_mongrel, true)
end

task :start_master, :roles => :app do
  run "cd #{latest_release} && lib/daemons/master_ctl start" if fetch(:restart_daemons, true)
  run "/etc/init.d/lighttpd start" if fetch(:restart_lighttpd, true)
  run "/usr/bin/mongrel_cluster_ctl start" if fetch(:restart_mongrel, true)
end

desc "Load default data."
task :load_default_data, :roles => :app do
  run "RAILS_ROOT=#{latest_release} RAILS_ENV=production FIXTURES=config_params,profiles,roles,measures,roles_static_permissions,static_permissions rake -f #{latest_release}/Rakefile db:YAML:restore"
end
