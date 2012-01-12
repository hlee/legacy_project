require File.dirname(__FILE__) + '/../test_helper'
require 'config_params_controller'

# Re-raise errors caught by the controller.
class ConfigParamsController; def rescue_action(e) raise e end; end

class ConfigParamsControllerTest < Test::Unit::TestCase
  fixtures :config_params, :users, :static_permissions, :roles, :roles_static_permissions, :roles_users

  def setup
    @controller = ConfigParamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = ConfigParam.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template "list"
  end

  def test_list
    get :list
    assert_response :success
    assert_template "list"
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:config_param)
    assert assigns(:config_param).valid?
  end


  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:config_param)
    assert assigns(:config_param).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert_equal(flash[:notice], "ConfigParam was successfully updated.")
  end

  def test_destroy
    myConfigParam = ""
    assert_nothing_raised {
      myConfigParam = ConfigParam.find(@first_id)
    }
    # Verify the parameter was not deleted
    assert_nothing_raised {
      ConfigParam.find(myConfigParam.id)
    }
  end
end
