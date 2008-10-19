require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  def test_host_should_return_user
    event = Event.find(1)
    assert_kind_of User, event.host
  end
  
  def test_host_should_be_required
    event = Event.create
    assert event.errors.on(:host)
    assert event.errors.on(:host_id)
  end
  
  def test_has_tickets
    assert events(:jon_schmidt).tickets
  end
  
  def test_saving_event_with_a_blank_flickr_feed
    assert events(:metallica).update_attributes(:flickr_feed_url => '')
  end
  
  def test_flickr_feed_url_should_be_set_when_saved
    event = events(:metallica)
    event.flickr_feed_url = nil
    assert !event.flickr_feed_url
    event.save!
    assert event.flickr_feed_url
  end
  
  def test_flickr_images_should_return_an_array_of_flickr_image_objects
    event = events(:metallica)
    assert event.flickr_images
    assert event.flickr_images.any? {|image| image.src == 'http://farm2.static.flickr.com/1068/1342103625_8711877743_m.jpg' }
    assert event.flickr_images.any? {|image| image.href == 'http://www.flickr.com/photos/jackdanger/1269305133/' }
  end

  def test_flickr_images_should_return_12_items
    event = events(:metallica)
    assert_equal 10, event.flickr_images.length
  end
  
  def test_one_word_search_condition
    assert_equal ["foo like ?", '%bar%'], Event.search_conditions(%w[foo], 'bar')
  end
  
  def test_two_word_search_condition
    assert_equal ["foo like ? or bar like ?", '%blah%', '%blah%'], Event.search_conditions(%w[foo bar], 'blah')
  end
  
  def test_empty_search_condition_should_return_nil
    assert_nil Event.search_conditions(['foo', 'bar'], '')
  end
  
  def test_empty_search_should_return_all_records
    assert_equal Event.count, Event.search.size
  end
  
  def test_search_should_only_return_matching_records
    assert_equal 1, Event.search('Schmidt').size
  end
  
  def test_should_be_able_to_create_multiple_ticket_types
    event = Event.new(:new_ticket_types => { "0" => {:name => 'foo'}, "1" => {:name => 'bar'}})
    assert_equal %w[foo bar], event.ticket_types.map(&:name)
  end
  
  def test_should_be_able_to_update_multiple_ticket_types
    event = Event.find(1)
    event.attributes = {:edit_ticket_types => { "1" => {:name => 'foo'}}}
    event.save!
    assert_equal 'foo', TicketType.find(1).name
  end
  
  def test_should_ignore_blank_ticket_types
    event = Event.new(:new_ticket_types => { "0" => {:name => ''}, "1" => {:name => 'bar'}})
    assert_equal %w[bar], event.ticket_types.map(&:name)
  end
  
    
  def test_unlimited_tickets?
    event = events(:metallica)
    assert !event.unlimited_tickets?
    event.ticket_types.create!(:name => 'unlimited')
    assert event.unlimited_tickets?
  end
  
  def test_total_quantity
    event = events(:metallica)
    assert_equal 45, event.total_quantity
    event.ticket_types.create!(:quantity => 200, :name => '200')
    assert_equal 245, event.total_quantity
    event.ticket_types.create!(:name => 'unlimited')    
    assert_equal 'Unlimited', event.total_quantity
  end
  
  def test_tickets_remaining
    event = events(:jon_schmidt)
    assert (event.ticket_types.inject(0){|sum, tt| tt.quantity } - event.tickets.count), event.tickets_remaining
  end
  
  def test_should_be_able_to_handle_a_bad_flickr_url
    event = events(:jon_schmidt)
    ['@342 lkajf', "#{RAILS_ROOT}/test/test_helper.rb", nil, ''].each do |file|
      event.flickr_url = file
      event.save!
      assert_nil event.flickr_feed_url
    end
  end
  
  def test_should_have_brief_location
    assert_equal 'foo, bar, blah', Event.new(:city => 'foo', :state => 'bar', :country => 'blah').brief_location
    assert_equal 'foo, blah', Event.new(:city => 'foo', :country => 'blah').brief_location
  end
  
  def test_should_display_city_with_state
    assert_equal 'foo, bar blah', Event.new(:city => 'foo', :state => 'bar', :zip => 'blah').city_state_zip
    assert_equal 'foo, bar', Event.new(:city => 'foo', :state => 'bar').city_state_zip
    assert_equal 'bar', Event.new(:state => 'bar').city_state_zip
    assert_equal 'foo blah', Event.new(:city => 'foo', :zip => 'blah').city_state_zip
  end
  
  def test_earnings_should_add_ticket_type_earnings
    event = Event.new
    event.ticket_types.build.stubs(:earnings).returns(5)
    event.ticket_types.build.stubs(:earnings).returns(3)
    assert_equal 8, event.earnings
  end
  
  def test_format_validations_on_name
    assert Event.create(:name => 'go http://google.com here <-').errors.on(:name)
    assert Event.create(:name => 'go https://google.com here <-').errors.on(:name)
    assert !Event.create(:name => 'go google.com here <-').errors.on(:name)
  end

  def test_format_validations_on_description
    assert Event.create(:description => 'go http://google.com here <-').errors.on(:description)
    assert Event.create(:description => 'go https://google.com here <-').errors.on(:description)
    assert Event.create(:description => 'go <script>alert('')</script> here <-').errors.on(:description)
    assert !Event.create(:description => 'go google.com here <-').errors.on(:description)
  end
end
