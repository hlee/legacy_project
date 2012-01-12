require File.dirname(__FILE__) + '/../test_helper'
require 'livetrace_controller'

# Re-raise errors caught by the controller.
class LivetraceController; def rescue_action(e) raise e end; end

class LivetraceControllerTest < Test::Unit::TestCase
  def setup
    @controller = LivetraceController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
