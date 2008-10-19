require 'hpricot'

class Event < ActiveRecord::Base

  belongs_to :host, :class_name => 'User'
  has_one :graphic
  has_many :news_items
  has_many :ticket_types
  has_many :tickets, :through => :ticket_types
  
  acts_as_geocodable :address => {:street => :address, :locality => :city, :region => :state, :postal_code => :zip}
  
  validates_presence_of :name, :starts_at, :host_id, :host
  validates_associated :graphic, :ticket_types
  
  before_save :save_flickr_feed
  after_create :save_graphic
  after_save :save_all_ticket_types
  
  def new_ticket_types=(ticket_types_hash)
    ticket_types_hash.values.each do |attributes|
      ticket_types.build(attributes) unless attributes.values.all?(&:blank?)
    end
  end
  
  def edit_ticket_types=(ticket_types_hash)
    ticket_types.each do |t|
      t.attributes = ticket_types_hash[t.id.to_s]
    end
  end
  
  def validate
    errors.add_to_base('Event must have at least one ticket type') if ticket_types.empty?
    errors.add(:name, "can't have any urls in it") if name =~ /https?:\/\//
    errors.add(:description, "can't have any urls in it") if description =~ /https?:\/\//
    errors.add(:description, "can't have any script tags in it") if description =~ /<script/
  end
  
  def save_graphic
    graphic.save! if graphic
  end
  
  def has_map?
    geocode && geocode.latitude && geocode.longitude
  end
  
  def map
    @gmap = GoogleMap.new(:controls => [:small])
    @gmap.markers << GoogleMapMarker.new(:map => @gmap,
                                         :lat => self.geocode.latitude,
                                         :lng => self.geocode.longitude,
                                         :html => map_marker_html)
    @gmap
  end
  
  def map_marker_html
    "<iframe src='/events/#{id}.map' width='200' height='70' frameborder='0' marginheight='0' marginwidth='0' scrolling='no'></iframe>"
  end
  
  def unlimited_tickets?
    ticket_types.any? {|ticket_type| ticket_type.quantity.nil? }
  end
  
  def total_quantity
    return 'Unlimited' if unlimited_tickets?
    ticket_types.to_a.sum(&:quantity)
  end
  
  def tickets_remaining
    return 'Unlimited' if unlimited_tickets?
    ticket_types.to_a.sum(&:quantity_remaining)
  end
  
  def earnings
    ticket_types.to_a.sum(&:earnings)
  end
  
  def save_all_ticket_types
    # this may lead to a ticket type being saved multiple times
    # there's probably a better way to do this
    ticket_types.each(&:save!)
  end
  
  def full_address
    [address, city_state_zip].delete_if(&:blank?).join(', ')
  end
  
  def brief_location
    [city, state, country].delete_if(&:blank?).join(', ')
  end

  def city_state
    [city, state].delete_if(&:blank?).join(', ')
  end
  
  def city_state_zip
    [city_state, zip].delete_if(&:blank?).join(' ')
  end
  
  def has_flickr?
    !flickr_feed_url.blank?
  end
  
  def flickr_url=(url)
    self.flickr_feed_url = nil
    write_attribute(:flickr_url, url)
  end
  
  def flickr_images
    return [] unless flickr_feed_url
    get_images_from_atom(flickr_feed_url)
  end

  protected
  
    def save_flickr_feed
      return true if flickr_url.blank?
      return true if flickr_feed_url
      flickr_page = http_get(flickr_url)
      return true unless flickr_page
      self.flickr_feed_url = (Hpricot(flickr_page)/"link").find {|link| link.attributes['type'] == 'application/atom+xml' }.attributes['href']
    rescue
      true
    end
    
    def get_images_from_atom(url, length = 10)
      atom = http_get(url)
      if atom
        (Hpricot.XML(atom)/'entry')[0...length].collect do |entry|
          image = FlickrImage.new
          image.src = (Hpricot(CGI::unescapeHTML((entry/'content').first.inner_html))/'img').first.attributes['src']
          image.href = (entry/'link').find {|link| link.attributes['rel'] == 'alternate' }.attributes['href']
          image
        end
      end
    end
  
    def http_get(url)
      ENV['RAILS_ENV'].downcase.eql?('test') ?
        File.read("#{RAILS_ROOT}/test/fixtures/#{url}") :
        Net::HTTP.get(URI.parse(url))
    rescue
      nil
    end
  
  class << self
    
    def find_upcoming(limit = 10)
      with_upcoming_scope do
        find(:all, :limit => limit)
      end
    end
  
    def search(query = nil, page = nil, sort = nil, limit = 10)
      if sort.blank?
        order = 'starts_at'
      elsif sort == 'location'
        order = 'country, city, starts_at'
      else
        order = sanitize(sort)
      end
      with_upcoming_scope do
        conditions = search_conditions(%w[name description], query)
        paginate(:all, :order => order, :limit => limit, :conditions => conditions, :page => page)
      end
    end
  
    def search_conditions(columns, query)
      return nil if query.blank?
      conditions = columns.map { |c| "#{c} like ?" }
      [conditions.join(' or '), *(["%#{query}%"]*columns.size)]
    end

    private

      def with_upcoming_scope(&block)
        with_scope(:find => { :order => 'starts_at', :conditions => 'starts_at >= NOW() or ends_at >= NOW()' }, &block)
      end
  end
end
