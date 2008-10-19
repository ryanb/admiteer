class Graphic < ActiveRecord::Base
  belongs_to :event
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes,
                 :resize_to => '480x120'
                 
  validates_as_attachment
end
