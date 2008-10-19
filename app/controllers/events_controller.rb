class EventsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  
  def index
    @events = Event.search(params[:query], params[:page], params[:sort])
    respond_to do |wants|
      wants.html
      wants.rss
    end
  end
  
  def show
    @event = Event.find(params[:id], :include => :news_items)
    respond_to do |wants|
      wants.html
      wants.rss
      wants.map
    end
  end
  
  def new
    @event = Event.new
    @event.ticket_types.build(:name => 'General Admission')
    @event.starts_at = 1.day.from_now.beginning_of_day + 8.hours
    @event.ends_at = @event.starts_at + 9.hours
  end
  
  def create
    @event = current_user.events.new(params[:event])
    @graphic = @event.build_graphic(params[:graphic]) if should_handle_upload?
    if @event.save
      redirect_to @event
    else
      render :action => 'new'
    end
  end
  
  def edit
    @event = current_user.events.find(params[:id])
  end
  
  def update
    @event = Event.find(params[:id])
    @graphic = @event.build_graphic(params[:graphic]) if should_handle_upload?
    if @event.update_attributes(params[:event])
      flash[:notice] = "Successfully updated event."
      redirect_to event_path(@event)
    else
      render :action => 'edit'
    end
  end
  
  def share
    @event = Event.find(params[:id])
    render :layout => false
  end
  
  
  protected
  
  def should_handle_upload?
    params[:graphic] && !params[:graphic][:uploaded_data].blank? && $image_science_installed
  end
end
