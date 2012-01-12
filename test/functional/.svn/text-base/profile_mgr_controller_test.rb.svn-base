require File.dirname(__FILE__) + '/../test_helper'
require 'profile_mgr_controller'

# Re-raise errors caught by the controller.
class ProfileMgrController; def rescue_action(e) raise e end; end

class ProfileMgrControllerTest < Test::Unit::TestCase
  fixtures :profiles, :switch_ports, :switches, :datalogs

  def setup
    @controller = ProfileMgrController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    prf=Profile.new({:name=>'prof1',:comment=>'this is a test',:status=>0})
    prf.major_offset = 20
    prf.minor_offset = 10
    prf.save()

    @first_id = Profile.find(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:profiles)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:profile)
  end

  def test_create
    num_profiles = Profile.count

    post :create, :profile => {:name => "test", :major_offset => 20, :minor_offset => 10 }

    assert_response :redirect
    puts num_profiles
    puts Profile.count
    #assert_equal num_profiles + 1, Profile.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:profile)
    #assert assigns(:profile).valid?
  end

  def test_update
    post :update, :id => @first_id
    #assert_response :redirect
    #assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Profile.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #assert_raise(ActiveRecord::RecordNotFound) {
      #Profile.find(@first_id)
    #}
  end
=begin  
  def test_generate
    #Should generate an error because switch_port_id=4 is a forward path port.
    post :generate, {'switch_port' =>{'1' => '1','2' => '1', '3' => '0','4'=>'1'},
       'major_offset'=>'10','minor_offset' =>'5','hours'=>3, 'link_loss' => '1'}
    assert flash.has_key?(:error)
    assert_response :redirect

    #should generate an error if the hours field is not there.
    post :generate, {'switch_port'=>{'1' => '1','2' => '1', '3' => '0','4'=>'0'},
       'major_offset'=>'10','minor_offset' =>'5', 'hours'=>3, 'link_loss' => '1'}
    #assert !flash.empty? , flash[:error]
    #assert_equal "Switch port Does not have a site.", flash[:error]
    #assert_response :redirect

    #should generate an error if the hours field is not there.
    post :generate, {'switch_port'=>{'1' => '1','2' => '1', '3' => '0','4'=>'0'},
       'major_offset'=>'10','minor_offset' =>'5', 'link_loss' => '1'}
    assert !flash.empty? , flash[:error]
    assert_equal "Hours field required.", flash[:error]
    assert_response :redirect

    #should generate an error if the minor offset field is not there.
    post :generate, {'switch_port'=>{'1' => '1','2' => '1', '3' => '0','4'=>'0'},
       'major_offset'=>'10','hours'=>3, 'link_loss' => '1'}
    assert !flash.empty? , flash[:error]
    assert_equal "Minor offset is required.", flash[:error]
    assert_response :redirect

    #should generate an error if the major offset field is not there.
    post :generate, {'switch_port'=>{'1' => '1','2' => '1', '3' => '0','4'=>'0'},
       'minor_offset' =>'5','hours'=>3, 'link_loss' => '1'}
    assert !flash.empty? , flash[:error]
    assert_equal "Major offset is required.", flash[:error]
    assert_response :redirect

    #Should generate an error if the site is not specified for the switch port.
    post :generate, {'switch_port'=>{'1' => '1','2' => '1', '3' => '0','4'=>'0'},
       'major_offset'=>'10','minor_offset' =>'5','hours'=>3, 'link_loss' => '1'}
    assert !flash.empty? , flash[:error]
    assert_equal "Switch port Does not have a site.", flash[:error]
    assert_response :redirect
    post :generate, {'switch_port'=>{'1' => '1','2' => '0', '3' => '1','4'=>'0'},
       'major_offset'=>'10','minor_offset' =>'5','hours'=>3, 'link_loss' => '1'}
    assert_response :redirect

  end
=end
end
