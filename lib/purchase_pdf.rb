class PurchasePDF
  def initialize(purchase)
    @purchase = purchase
    @pdf = PDF::Writer.new
  end
  
  def self.render(purchase)
    self.new(purchase).draw
  end
  
  def draw
    ticket_index = 0
    @purchase.tickets.in_groups_of(4, false) do |tickets|
      @pdf.translate_axis(50, 575)
      @pdf.scale_axis(1.1, 1.1)
      tickets.each do |ticket|
        TicketDrawer.new(@pdf, ticket, ticket_index).draw
        @pdf.translate_axis(0, -160)
        ticket_index += 1
      end
      @pdf.start_new_page unless tickets.last == @purchase.tickets.last
    end
    @pdf.render
  end
end


class TicketDrawer
  def initialize(pdf, ticket, index)
    @pdf = pdf
    @ticket = ticket
    @index = index
  end
  
  def draw
    @pdf.select_font "Helvetica"
    @pdf.font_size = 11
    draw_background_image
    draw_uuid
    draw_event_time
    draw_purchase_info
    draw_index
    draw_event_name
    draw_event_details
  end
  
  private
  
  def draw_background_image
    @pdf.add_image(background_image, 0, 0, 350)
  end
  
  def draw_uuid
    @pdf.add_text 210, 129, @ticket.uuid
  end
  
  def draw_event_time
    @pdf.add_text 45, 129, event.starts_at.strftime('%b %d, %Y at %I:%M %p')
  end
  
  def draw_purchase_info
    @pdf.add_text 45, 100, purchase_details.join(' - ')
  end
  
  def draw_index
    change_font_size 10 do
      text = "#{@index+1} of #{purchase.quantity}"
      width = @pdf.text_width(text)
      @pdf.add_text 341-width, 10, text
    end
  end
  
  def draw_event_name
    change_font_size 16 do
      @pdf.add_text 45, 65, event.name
    end
  end
  
  def draw_event_details
    x = 51
    change_font_size 11 do
      event_detail_lines.each do |line|
        @pdf.add_text 45, x, line
        x -= 11
      end
    end
  end
  
  def background_image
    File.read("#{RAILS_ROOT}/public/images/ticket.jpg")
  end
  
  def event_detail_lines
    [event.address, event.city_state_zip, event.country, event.phone].delete_if(&:blank?)
  end
  
  def purchase_details
    details = []
    details << purchase.created_at.strftime('%m/%d/%Y')
    details << purchase.buyer.full_name
    details << purchase.buyer.email
    details.delete_if(&:blank?)
  end
  
  def event
    @ticket.event
  end
  
  def purchase
    @ticket.purchase
  end
  
  def change_font_size(font_size)
    old_font_size = @pdf.font_size
    @pdf.font_size = font_size
    yield
    @pdf.font_size = old_font_size
  end
end
