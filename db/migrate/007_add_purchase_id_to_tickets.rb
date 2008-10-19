class AddPurchaseIdToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :purchase_id, :integer
  end

  def self.down
    remove_column :tickets, :purchase_id
  end
end
