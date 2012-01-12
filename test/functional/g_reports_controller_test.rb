require File.dirname(__FILE__) + '/../test_helper'
require 'g_reports_controller'

# Re-raise errors caught by the controller.
class GReportsController; def rescue_action(e) raise e end; end

class GReportsControllerTest < Test::Unit::TestCase

  #fixtures :data

  def setup
    @controller = GReportsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO Replace this with your actual tests
  def test_show
    get :show
    assert_response :success
    assert_equal 'image/png', @response.headers['type']
  end
  
end
