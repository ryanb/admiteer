require File.dirname(__FILE__) + '/../test_helper'

class PurchaseTest < Test::Unit::TestCase

  def test_should_have_a_buyer_association
    assert Purchase.new.respond_to?(:buyer)
  end
  
  def test_should_have_a_tickets_collection
    assert Purchase.new.tickets
  end

  def event
    purchase = Purchase.find(1)
    purchase.tickets.create!(:ticket_type => ticket_types(:jon_schmidt_front_row))
    assert_equal events(:jon_schmidt), purchase.event
  end
  
  def test_should_require_a_buyer
    purchase = Purchase.create
    assert purchase.errors.on(:buyer)
    assert purchase.errors.on(:buyer_id)
  end
  
  def test_paypal_url
    purchase = Purchase.create(:buyer => users(:quentin), :quantity => 2, :ticket_type_id => ticket_types(:jon_schmidt_front_row).id)
    assert purchase.paypal_url('http://admiteer.com') =~ /quantity=2/
    assert purchase.paypal_url('http://admiteer.com') =~ /item_number=Jon Schmidt Front Row/
    assert purchase.paypal_url('http://admiteer.com') =~ /item_name=Jon Schmidt Concert/
    assert purchase.paypal_url('http://admiteer.com') =~ /business=#{users(:quentin).email}/
    assert purchase.paypal_url('http://admiteer.com') =~ /return=http:\/\/admiteer.com/
  end
  
  def test_paid
    purchase = Purchase.find(1)
    purchase.update_attribute(:paid_at, nil)
    assert !purchase.paid?
    purchase.paid!
    assert purchase.paid?
  end
  
  def test_free?
    purchase = Purchase.find(1)
    assert !purchase.free?
    purchase.ticket_type.update_attributes!(:cost_per_ticket => nil)
    assert purchase.free?
    purchase.ticket_type.update_attributes!(:cost_per_ticket => '48.56')
    purchase.quantity = 0
    assert purchase.free?
  end
  
  def test_should_cache_ticket_cost
    ticket_type = TicketType.create!(:name => 'foo', :cost_per_ticket => 20)
    purchase = ticket_type.purchases.create!(:buyer_id => 1, :quantity => 5)
    assert_equal 100, purchase.total_cost
    ticket_type.update_attribute(:cost_per_ticket, 50)
    assert_equal 100, purchase.total_cost
    purchase.update_attribute(:quantity, 6)
    assert_equal 120, purchase.total_cost
  end
  
  def test_event_should_be_set_when_setting_ticket_type
    purchase = Purchase.new(:ticket_type_id => 1)
    assert_not_nil purchase.event
  end
  
end
