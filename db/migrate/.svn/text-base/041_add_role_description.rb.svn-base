class AddRoleDescription < ActiveRecord::Migration
  def self.up
    add_column "roles", "description", :string

    require 'rake'
    rake = Rake::Application.new
    ENV['FIXTURES'] = "roles,static_permissions,roles_static_permissions"
    Rake::Task["db:YAML:delete"].invoke
    Rake::Task["db:YAML:restore"].invoke

    user = User.new({:email => 'admin'})
    user.password = 'password'
    user.password_confirmation = 'password'
    if user.save
      puts "Created USER #{user.email}"
    else
      puts "Error creating user.  #{user.errors.inspect}"
    end
    user.roles << Role.find(:all)
    user.save
  end

  def self.down
    remove_column "roles", "description"
    user = User.find_by_email('admin')
    user.destroy
  end
end
