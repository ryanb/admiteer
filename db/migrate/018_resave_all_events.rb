class ResaveAllEvents < ActiveRecord::Migration
  def self.up
    Event.find(:all).each(&:save)
  end

  def self.down
  end
end
