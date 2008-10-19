class FixPurchasese < ActiveRecord::Migration
  def self.up
    Purchase.find(:all, :conditions => "quantity is null or ticket_type_id is null or cost_per_ticket is null or paid_at is null").each do |p|
      if p.tickets.blank?
        p.destroy
      else
        puts "fixing purchase ##{p.id}"
        ticket_type = p.tickets.first.ticket_type
        p.ticket_type = ticket_type
        p.quantity ||= p.tickets.length
        p.cost_per_ticket ||= ticket_type.cost_per_ticket
        p.buyer ||= User.find(:first)
        p.paid_at ||= Time.now
        p.save!
      end
    end
  end

  def self.down
  end
end
