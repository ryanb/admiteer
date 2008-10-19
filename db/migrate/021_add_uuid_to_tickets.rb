class AddUuidToTickets < ActiveRecord::Migration
  def self.up
    add_column :tickets, :uuid, :string
  end

  def self.down
    remove_column :tickets, :uuid
  end
end
