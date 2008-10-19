class AddTicketTypeIdAndQuantityToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :ticket_type_id, :integer
    add_column :purchases, :quantity, :integer
  end

  def self.down
    remove_column :purchases, :ticket_type_id
    remove_column :purchases, :quantity
  end
end
