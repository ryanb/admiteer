require File.dirname(__FILE__) + '/../test_helper'
require 'news_items_controller'

# Re-raise errors caught by the controller.
class NewsItemsController; def rescue_action(e) raise e end; end

class NewsItemsControllerTest < Test::Unit::TestCase
  def setup
    @controller = NewsItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_have_new_action
    login!
    get 'new', :event_id => 1
    assert_template 'new'
  end
  
  def test_should_have_create_action
    login!
    post 'create', :event_id => 1, :news_item => { :content => 'foo' }
    assert_redirected_to event_path(1)
  end
  
  def test_should_require_ownership
    login_as(:aaron)
    get 'new', :event_id => 1
    assert_redirected_to signup_path
  end
end
