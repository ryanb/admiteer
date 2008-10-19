require 'digest/sha1'

module ActiveRecordUUID
  def self.included(target)
    target.send :include, UUIDClassMethods
  end
  
  module UUIDClassMethods
    def generate_uuid
      return if new_record?
      str = '0123456789abcdefghijklmnopqrstuvwxyz'
      parts = []
      7.times { parts << str[rand(35)].chr }
      parts << '-'
      5.times { parts << str[rand(35)].chr }
      parts << '-'
      parts << ('%7i' % self.id).gsub(' ', '0')
      parts.join
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecordUUID