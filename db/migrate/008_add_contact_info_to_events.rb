class AddContactInfoToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :address, :string
    add_column :events, :city, :string
    add_column :events, :zip, :string
    add_column :events, :state, :string
    add_column :events, :country, :string
    add_column :events, :phone, :string
  end

  def self.down
    remove_column :events, :address
    remove_column :events, :city
    remove_column :events, :zip
    remove_column :events, :state
    remove_column :events, :country
    remove_column :events, :phone
  end
end
