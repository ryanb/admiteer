class TicketType < ActiveRecord::Base
  belongs_to :event
  has_many   :tickets
  has_many   :purchases

  validates_presence_of :name
  
  before_destroy :only_if_no_purchases
  
  def free?
    cost_per_ticket.blank? || cost_per_ticket.zero?
  end
  
  def quantity_remaining
    quantity - quantity_purchased if quantity
  end
  
  def quantity_purchased
    purchases.to_a.sum(&:quantity)
  end
  
  def earnings
    purchases.to_a.sum(&:total_cost)
  end
  
  protected
    
    def only_if_no_purchases
      purchases.blank? ? true : false
    end
end
