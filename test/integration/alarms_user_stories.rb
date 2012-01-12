require "#{File.dirname(__FILE__)}/../test_helper"

class UserStoriesTest < ActionController::IntegrationTest
  fixtures :roles, :static_permissions, :roles_static_permissions, :users, :config_params

  def setup
    # By default, the application skips authentication in tests.
    # We want it to require authentication here.
    ENV["SKIP_AUTH"] = "no"

    # config_params sets license to none, we want both
    license = ConfigParam.find_by_name("License")
    assert !license.nil?, "Could not find ConfigParam 'license'"
    license.val = "BOTH"
    assert license.save, "ERROR: Unable to set license code to BOTH (ERROR: #{license.errors.full_messages})"
  end

  # Replace this with your real tests.
  def test_find_admin_user
    user = User.find_by_email('admin')
    assert !user.nil?, "Could not find User 'admin'"
  end

  def test_get_main_index
    get "/"
    assert_response :success
    assert_template "main/index"
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
    follow_redirect!()
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

  def login(username='', password='')
    post_via_redirect "/auth/login",
      :user => {
        :email => username,
        :password => password
      }
    assert_response :success
    assert_template "main/index"
  end
end
