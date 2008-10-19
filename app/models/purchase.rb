class Purchase < ActiveRecord::Base

  belongs_to :buyer, :class_name => 'User'
  belongs_to :ticket_type
  has_many :tickets
  
  before_create :cache_cost_per_ticket

  validates_presence_of :buyer
  validates_presence_of :buyer_id
  validates_presence_of :ticket_type
  validates_presence_of :ticket_type_id
  validates_presence_of :quantity
  
  attr_protected :cost_per_ticket, :paid_at
  
  def event
    return unless ticket_type
    ticket_type.event
  end

  def total_cost
    (cost_per_ticket || 0) * (quantity || 0)
  end
  
  def cost_per_ticket
    self[:cost_per_ticket] || ticket_type.cost_per_ticket
  end
  
  def free?
    total_cost < 1
  end
  
  def paypal_url(return_url)
    return if new_record?
    values = {
      :business => event.host.email,
      :item_name => event.name,
      :item_number => ticket_type.name,
      :amount => ticket_type.cost_per_ticket,
      :quantity => quantity,
      :no_shipping => 1,
      :no_note => 1,
      :currency_code => 'USD',
      :lc => 'US',
      :charset => 'UTF-8',
      :return => return_url,
      :cmd => '_xclick'
    }
    "https://www.paypal.com/cgi-bin/webscr?"+values.map {|k,v| "#{k}=#{v}" }.join("&")
  end
  
  def paid!
    return paid_at if paid?
    self.paid_at = Time.now
    save!
    create_tickets
  end
  
  def paid?
    paid_at
  end
  
  def validate_on_create
    if ticket_type && ticket_type.quantity_remaining && quantity > ticket_type.quantity_remaining
      errors.add_to_base('Not enough tickets available. Please go back to event and purchase fewer tickets.')
    end
  end
  
  protected
    def cache_cost_per_ticket
      self.cost_per_ticket = ticket_type.cost_per_ticket
    end
  
    def create_tickets
      quantity.times do
        self.tickets << ticket_type.tickets.create!(:purchase => self)
      end
    end  
end
