class AddPaidAtToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :paid_at, :datetime
  end

  def self.down
    remove_column :purchases, :paid_at
  end
end
