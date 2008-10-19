require File.dirname(__FILE__) + '/../test_helper'
require 'tickets_controller'

# Re-raise errors caught by the controller.
class TicketsController; def rescue_action(e) raise e end; end

class TicketsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TicketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_event_id_should_not_be_required_for_viewing_ticket
    get :show, :id => tickets(:jon_schmidt_front_row_1).id
    assert_response :success
  end

  def test_event_id_should_be_allowed_for_viewing_ticket
    get :show, :id => tickets(:jon_schmidt_front_row_1).id, :event_id => events(:jon_schmidt).id
    assert_response :success
  end

end
