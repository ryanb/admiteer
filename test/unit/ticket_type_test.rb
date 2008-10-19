require File.dirname(__FILE__) + '/../test_helper'

class TicketTypeTest < Test::Unit::TestCase
  def test_should_have_event_association
    assert TicketType.new.respond_to?(:event)
  end
  
  def test_should_have_ticket_collection
    assert TicketType.new.tickets
  end
  
  def test_can_destroy_new_ticket_types
    assert TicketType.create!(:event => events(:metallica), :name => 'x').destroy
  end

  def test_can_destroy_new_ticket_types
    assert TicketType.create!(:event => events(:metallica), :name => 'x').destroy
  end

  def test_cannot_destory_with_purchase
    assert !ticket_types(:metallica_front_row).destroy
  end
  
  def test_should_be_free_when_nil_or_zero
    assert TicketType.new(:cost_per_ticket => 0).free?
    assert TicketType.new.free?
    assert !TicketType.new(:cost_per_ticket => 5).free?
  end
  
  def test_should_calculate_quantity_purchased
    ticket_type = TicketType.new
    ticket_type.purchases.build(:quantity => 5)
    ticket_type.purchases.build(:quantity => 2)
    assert_equal 7, ticket_type.quantity_purchased
  end
  
  def test_should_calculate_quantity_remaining
    ticket_type = TicketType.new(:quantity => 30)
    ticket_type.purchases.build(:quantity => 5)
    ticket_type.purchases.build(:quantity => 2)
    assert_equal 23, ticket_type.quantity_remaining
  end
  
  def test_earnings_should_be_total_of_purchase_costs
    ticket_type = TicketType.new
    ticket_type.purchases.build.stubs(:total_cost).returns(5)
    ticket_type.purchases.build.stubs(:total_cost).returns(3)
    assert_equal 8, ticket_type.earnings
  end
end
