class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.column :buyer_id, :integer
      t.timestamps 
    end
  end

  def self.down
    drop_table :purchases
  end
end
