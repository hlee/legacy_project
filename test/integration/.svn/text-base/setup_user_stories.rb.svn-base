require "#{File.dirname(__FILE__)}/../test_helper"

class UserStoriesTest < ActionController::IntegrationTest
  fixtures :roles, :static_permissions, :roles_static_permissions, :users, :config_params

  def setup
    # By default, the application skips authentication in tests.
    # We want it to require authentication here.
    ENV["SKIP_AUTH"] = "no"
  end

  def teardown
    logout
  end

  def test_find_admin_user
    user = User.find_by_email('admin')
    assert !user.nil?, "Could not find User 'admin'"
    assert_equal 'admin', user.email
    assert_equal 1, user.id
    assert user.password_equals?('password'), "User #{user.email}'s password is not set to password"
  end

  def test_get_main_index_no_license
    license = get_license
    assert_equal "NEITHER", license
    get "/"
    assert_response :redirect
    assert_redirected_to :controller => 'config_params', :action => 'list'
    follow_redirect!
    assert_response :redirect
    assert_redirected_to :controller => 'auth', :action => 'login'
    
    login('admin', 'password')
    assert_response :success
    assert_template "config_params/list"
  end

  def test_update_license
    license = get_license
    assert_equal "NEITHER", license

    login('admin', 'password')
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_template "config_params/list"

    post_via_redirect "/config_params/update/38",
      :config_param => {
        :val => "BOTH"
      }
    assert_response :success
    assert_template "config_params/list"
    license2 = get_license
    assert_equal "BOTH", license2
  end

  def test_click_setup_tab
    # User clicked the setup tab
    get "/network/index"
    assert_response :success
    assert_template "network/index"
  end

  def test_edit_users_not_logged_in
    # User clicked User Mgr Link (not logged in)
    get "/users"
    assert_response :redirect
    assert_redirected_to :controller => 'auth', :action => 'login'
    follow_redirect!
    assert_response :success
    assert_template "auth/login"
  end

  def test_edit_users_logged_in
    # User clicked User Mgr Link (logged in)
    login('admin','password')
    get "/users"
    assert_response :success
    assert_template "users/list"
  end

  def test_add_admin_user(username = 'admin2')
    # User clicked User Mgr Link (logged in)
    login('admin','password')
    get "/users"
    assert_response :success
    assert_template "users/list"

    get "/users/new"
    assert_response :success
    assert_template "users/new"
    post "/users/create",
      :user => {
        :email => username,
        :password => 'password',
        :password_confirmation => 'password',
      }
    assert_redirected_to(:controller => 'users', :action => 'roles', :id => User.find_by_email(username).id)
    follow_redirect!
    assert_response :success
    assert_template "users/roles"
    user = User.find_by_email(username)
    user_admin_role = Role.find_by_display_name("User Admin")
    post "/users/permissions/#{user.id}",
      :checkbox => {
        user_admin_role.id => '1'
      }
    assert_redirected_to(:controller => 'users', :action => 'list', :id => nil)
    follow_redirect!
    assert_response :success
    assert_template "users/list"
  end

  def test_add_normal_user(username = 'admin2')
    # User clicked User Mgr Link (logged in)
    login('admin','password')
    get "/users"
    assert_response :success
    assert_template "users/list"

    get "/users/new"
    assert_response :success
    assert_template "users/new"
    post "/users/create",
      :user => {
        :email => username,
        :password => 'password',
        :password_confirmation => 'password',
      }
    assert_redirected_to(:controller => 'users', :action => 'roles', :id => User.find_by_email(username).id)
    follow_redirect!
    assert_response :success
    assert_template "users/roles"
    user = User.find_by_email(username)
    post "/users/permissions/#{user.id}",
      :checkbox => {
        "0" => "0"
      }
    assert_redirected_to(:controller => 'users', :action => 'list', :id => nil)
    follow_redirect!
    assert_response :success
    assert_template "users/list"
  end

  def test_delete_admin_user
    user_admin_role = Role.find_by_display_name("User Admin")
    assert_equal 1, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length, "Initial import should only have one user with User Admin role"

    # Add another admin user
    test_add_admin_user("admin3")
    assert_equal 2, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length, "Calling test_add_admin_user should resulted in two users with User Admin role"

    # Add another admin user
    test_add_admin_user("admin4")
    assert_equal 3, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length, "Calling test_add_admin_user should resulted in three users with User Admin role"

    # We should have three user_admin users
    assert_equal 3, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length

    # Delete one and verify we have two left
    user = User.find(:first, :conditions => ['email <> ?', "admin"])
    assert user.destroy
    assert_equal 2, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length

    # Delete one and verify we have one left
    user = User.find(:first, :conditions => ['email <> ?', "admin"])
    assert user.destroy
    assert_equal 1, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length

    # Delete last user and verify it doesn't let us
    user = User.find(:first)
    user.errors.clear
    assert !user.destroy, "Last user_admin user should not be able to be deleted"
    assert_equal "Unable to delete last user with user_admin role", user.errors.full_messages[0]
    assert_equal 1, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length

    # Add another user without user_admin roles
    test_add_normal_user("user1")
    assert_equal 1, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length, "Calling test_add_admin_user should resulted in three users with User Admin role"

    # Verify we can delete non user_admin users even though
    # there is only one user_admin user
    user = User.find_by_email("user1")
    assert !user.nil?
    assert user.destroy
    assert_equal 1, User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length, "Calling test_add_admin_user should resulted in three users with User Admin role"
  end
  def test_no_duplicate_emails
    # Add another user without user_admin roles
    User.delete_all 'email like "user%"'
    user = User.new(:email => 'user1')
    user.errors.clear
    user.password = "password"
    user.password_confirmation = "password"
    assert user.save
    user2 = User.new(:email => 'user1')
    user2.errors.clear
    user2.password = "password"
    assert !user2.save
    assert_equal "has already been taken", user2.errors.on(:email)
    assert_equal "must match the confirmation", user2.errors.on(:password)
    user2.errors.clear
    user2.email = 'user2'
    assert !user2.valid?
    user2.password_confirmation = "password2"
    assert_equal "must match the confirmation", user2.errors.on(:password)
    user2.errors.clear
    user2.password_confirmation = "password"
    assert user2.save
  end

  def login(username='', password='')
    post_via_redirect "/auth/login",
      :user => {
        :email => username,
        :password => password
      }
  end

  def logout
    get "/auth/login"
  end
end
