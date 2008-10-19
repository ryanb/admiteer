class CreateGraphics < ActiveRecord::Migration
  def self.up
    create_table :graphics do |t|
      t.integer :event_id
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
    end
  end

  def self.down
    drop_table :graphics
  end
end
