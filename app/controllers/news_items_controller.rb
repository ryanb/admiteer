class NewsItemsController < ApplicationController
  before_filter :build_news_item
  before_filter :login_required
  
  def new
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    @news_item.save!
    respond_to do |format|
      format.html { redirect_to @event }
      format.js
    end
  end
  
  protected
  
  def build_news_item
    @event = Event.find(params[:event_id])
    @news_item = @event.news_items.build(params[:news_item])
  end
  
  def authorized?
    logged_in? && current_user.owns_event?(@event)
  end
end
