require File.dirname(__FILE__) + '/../test_helper'
require 'info_controller'

# Re-raise errors caught by the controller.
class InfoController; def rescue_action(e) raise e end; end

class InfoControllerTest < Test::Unit::TestCase
  def setup
    @controller = InfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_have_about_action
    get 'about'
    assert_template 'about'
  end
end
