require File.dirname(__FILE__) + '/../test_helper'
require 'purchases_controller'

# Re-raise errors caught by the controller.
class PurchasesController; def rescue_action(e) raise e end; end

class PurchasesControllerTest < Test::Unit::TestCase

  def setup
    @controller = PurchasesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login!
  end

  def test_show_should_make_the_right_number_of_tickets
    @request.env["HTTP_REFERER"] = 'https://www.paypal.com/_xclick'
    purchase = Purchase.create!(:buyer => users(:quentin), :ticket_type_id => ticket_types(:metallica_front_row), :quantity => 2)
    assert_equal 0, purchase.tickets.reload.length
    get :show, :id => purchase.id
    assert_equal 2, assigns(:purchase).tickets.reload.length
  end
  
  def test_create_should_send_the_user_on_to_paypal
    post :create, :purchase => {:ticket_type_id => ticket_types(:metallica_front_row).id, :quantity => '2'}
    assert @response.redirected_to =~ /^https:\/\/www.paypal/
  end
  
  def test_create_should_send_user_to_purchase_path_when_tickets_are_free
    post :create, :purchase => {:ticket_type_id => ticket_types(:free_event).id, :quantity => '2'}
    assert_redirected_to purchase_path(assigns(:purchase))
  end
  
  def test_create_should_redirect_to_login_for_guests
    logout!
    post :create, :purchase => {:ticket_type_id => ticket_types(:metallica_front_row).id, :quantity => '2'}
    assert_redirected_to signup_path
  end

  def test_show_should_set_paid_at
    @request.env["HTTP_REFERER"] = 'https://www.paypal.com/_xclick'
    purchase = purchases(:quentin_buys_metallica)
    purchase.update_attribute(:paid_at, nil)
    assert !purchase.paid?
    get :show, :id => purchase.id
    assert purchase.reload.paid?
  end

  def test_show_should_render_show_page
    purchase = purchases(:quentin_buys_metallica)
    purchase.paid_at = Time.now
    purchase.save!
    get :show, :id => purchase.id
    assert_template 'show'
  end
  
  def test_should_render_pdf
    purchase = purchases(:quentin_buys_metallica)
    purchase.paid_at = Time.now
    purchase.save!
    get :show, :id => purchase.id, :format => 'pdf'
    assert_response :success
  end
  
  def test_should_redirect_when_attempting_to_display_unpaid_purchase
    purchase = purchases(:quentin_buys_metallica)
    purchase.paid_at = nil
    purchase.save!
    get :show, :id => purchase.id
    assert_redirected_to dashboard_path
  end

end
