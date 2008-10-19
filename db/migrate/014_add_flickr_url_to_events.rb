class AddFlickrUrlToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :flickr_url, :string
  end

  def self.down
    remove_column :events, :flickr_url
  end
end
