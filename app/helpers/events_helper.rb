module EventsHelper
  def ticket_type_cost_and_quantity(ticket_type)
    sections = []
    sections << "#{ticket_type.quantity_remaining} available" if ticket_type.quantity?
    sections << price_or_free(ticket_type.cost_per_ticket) + (ticket_type.free? ? '' : " each")
    sections.join(' for ') + tag(:br) unless sections.empty?
  end
  
  def image_from_graphic(graphic)
    image_tag graphic.public_filename, :width => graphic.width, :height => graphic.height
  end
  
  def join_ticket_types(ticket_types)
    ticket_types.map do |ticket_type|
      "#{ticket_type.name} (#{price_or_free(ticket_type.cost_per_ticket)})"
    end.join(', ')
  end
  
  def price_or_free(price)
    if price.blank? || price.zero?
      'FREE'
    else
      number_to_currency(price)
    end
  end
end
