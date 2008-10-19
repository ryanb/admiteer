class Ticket < ActiveRecord::Base
  belongs_to :ticket_type
  belongs_to :purchase
  
  validates_presence_of :purchase_id
  validates_presence_of :purchase
  
  before_save :set_uuid
  
  def event
    ticket_type && ticket_type.event
  end
    
  protected
  
    def set_uuid
      self.uuid = generate_uuid if uuid.blank?
    end
end
