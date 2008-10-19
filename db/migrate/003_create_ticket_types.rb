class CreateTicketTypes < ActiveRecord::Migration
  def self.up
    create_table :ticket_types do |t|
      t.string :name
      t.integer :event_id
      t.decimal :cost_per_ticket, :precision => 10, :scale => 2
      t.integer :quantity
      t.timestamps 
    end
  end

  def self.down
    drop_table :ticket_types
  end
end
