class AddPriceToPurchase < ActiveRecord::Migration
  def self.up
    add_column :purchases, :cost_per_ticket, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :purchases, :cost_per_ticket
  end
end
