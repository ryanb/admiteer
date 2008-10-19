require File.dirname(__FILE__) + '/../test_helper'
require 'ticket_types_controller'

# Re-raise errors caught by the controller.
class TicketTypesController; def rescue_action(e) raise e end; end

class TicketTypesControllerTest < Test::Unit::TestCase
  def setup
    @controller = TicketTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  def test_index_should_be_accessible_to_host
    login!
    get :index, :event_id => events(:jon_schmidt).id
    assert_response :success
  end
  
  def test_index_should_render_index_template
    login!
    get :index, :event_id => events(:jon_schmidt).id
    assert_template 'ticket_types/index'
  end

  def test_show_should_render_show_template
    login!
    get :show, :id => ticket_types(:jon_schmidt_front_row).id, :event_id => events(:jon_schmidt).id
    assert_template 'ticket_types/show'
  end

  def test_new_should_render_rjs_template
    login!
    get 'new'
    assert_template 'new'
  end

  def test_destroy_should_render_rjs_template
    login!
    get 'destroy', :id => 1
    assert_template 'destroy'
  end
end
