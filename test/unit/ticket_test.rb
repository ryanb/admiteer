require File.dirname(__FILE__) + '/../test_helper'

class TicketTest < Test::Unit::TestCase

  def test_should_have_ticket_type_association
    assert Ticket.new.respond_to?(:ticket_type)
  end
  
  def test_should_have_purchase_association
    assert Ticket.new.respond_to?(:purchase)
  end
  
  def test_should_require_purchase
    ticket = Ticket.create
    assert ticket.errors.on(:purchase_id)
    assert ticket.errors.on(:purchase)
  end
  
  def test_uuid_should_raise_no_errors
    tickets(:jon_schmidt_front_row_1).save!
    assert tickets(:jon_schmidt_front_row_1).uuid
  end
  
  def test_event_should_be_available_through_ticket_type
    assert_equal events(:jon_schmidt), tickets(:jon_schmidt_front_row_1).event
  end

end
