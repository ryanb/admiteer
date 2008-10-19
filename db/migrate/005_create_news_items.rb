class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.integer :event_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
