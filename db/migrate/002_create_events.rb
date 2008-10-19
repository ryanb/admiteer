class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :host_id
      t.string :name
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
