class AddFlickrNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :flickr_name, :string
  end

  def self.down
    remove_column :users, :flickr_name
  end
end
