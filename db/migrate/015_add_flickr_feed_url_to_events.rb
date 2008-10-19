class AddFlickrFeedUrlToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :flickr_feed_url, :string
  end

  def self.down
    remove_column :events, :flickr_feed_url
  end
end
