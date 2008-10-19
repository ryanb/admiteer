require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'

require 'hpricot'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase
  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_render_index_template
    get 'index'
    assert_template 'index'
  end
  
  def test_as_rss_should_return_rss_content_type
    get :index, :format => 'rss'
    assert_equal 'application/rss+xml', @response.content_type
  end

  def test_index_rss_should_always_point_to_the_same_page
    get :index, :format => 'rss', :query => 'some_query'
    assert_equal 'http://test.host/events.html?query=some_query', (Hpricot.XML(@response.body)/'link').first.inner_html
  end
  
  def test_show_as_rss_should_return_rss_content_type
    get :show, :id => events(:metallica).id, :format => 'rss'
    assert_equal 'application/rss+xml', @response.content_type
  end

  def test_show_as_map_should_return_text_html_content_type
    get :show, :id => events(:metallica).id, :format => 'map'
    assert_equal 'text/html', @response.content_type
  end

  def test_should_render_show_template
    get 'show', :id => 1
    assert_template 'show'
  end
  
  def test_show_should_display_flickr_photos
    get 'show', :id => events(:metallica).id
    assert @response.body =~ /Latest Photos/
  end
  
  def test_show_should_not_display_photos_without_flickr_url
    event = events(:metallica)
    event.flickr_url, event.flickr_feed_url = nil, nil
    event.save!
    get 'show', :id => event.id
    assert @response.body !=~ /Latest Photos/
  end
  
  def test_show_should_display_map
    event = events(:metallica)
    event.save!
    get 'show', :id => event.id
    assert_tag :div, :attributes => {:id => 'gmap'}
  end
  
  def test_show_should_not_display_map_without_address
    get 'show', :id => events(:jon_schmidt).id
    assert_no_tag :div, :attributes => {:id => 'gmap'}
  end

  def test_should_render_new_template
    login!
    get 'new'
    assert_template 'new'
    assert_equal 1, assigns(:event).ticket_types.size
  end
  
  def test_should_redirect_to_event_after_create
    login!
    post 'create', :event => { :name => 'foo', :starts_at => Date.today, :new_ticket_types => { "0" => {:name => 'foo', :cost_per_ticket => '46.99'}} }
    assert_valid assigns(:event)
    assert_equal 1, assigns(:event).host_id
    assert_redirected_to event_path(assigns(:event))
  end
  
  def test_should_require_authentication_on_create
    logout!
    post 'create'
    assert_redirected_to signup_path
  end
  
  def test_should_require_authentication_on_new
    logout!
    get 'new'
    assert_redirected_to signup_path
  end
  
  def test_should_have_edit_action
    login!
    get 'edit', :id => '1'
    assert_template 'edit'
  end
end
