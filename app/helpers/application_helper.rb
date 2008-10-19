# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(title)
    content_for(:title) { title }
  end

  def add_to_head(content)
    content_for(:head) { content }
  end

  def display_date_range(start_date, end_date)
    return start_date.strftime("%b %d, %Y @ %l:%M %p") if start_date.to_date == end_date.to_date
    
    beginning_format = (start_date.year == end_date.year) ? "%b %d" : "%b %d, %Y"
    ending_format = (start_date.month == end_date.month) ? "%d, %Y" : "%b %d, %Y"
    "#{start_date.strftime(beginning_format)} - #{end_date.strftime(ending_format)}"
  end
  
  def highlight_if_exists(tag_id)
    javascript_tag "if($('#{tag_id}')){#{visual_effect :highlight, tag_id}}"
  end
  
  def swap_identity_links(name)
    link_to_function(name) { |p| p.toggle(:openid_fields, :password_fields) }
  end
  
  def swap_login_link(name)
    link_to_function(name) do |page|
      page.toggle :traditional_login, :openid_login
    end
  end
  
  def div_hidden_if(hidden, options = {}, &block)
    options[:style] = 'display: none' if hidden
    concat content_tag(:div, capture(&block), options), block.binding
  end
end
