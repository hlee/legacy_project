require File.dirname(__FILE__) + '/../test_helper'
require 'amf_services_controller'

# Re-raise errors caught by the controller.
class AmfServicesController; def rescue_action(e) raise e end; end

class AmfServicesControllerTest < Test::Unit::TestCase
  fixtures :sf_system_files, :sf_test_plans

  def setup
    @controller = AmfServicesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

  end

  def test_get_system_file_list
    get :get_system_file_list, :format => "xml"
    assert_response :success
  end

end
