class TicketTypesController < ApplicationController

  before_filter :login_required
  before_filter :find_event, :only => [:index, :show]
  before_filter :host_required, :only => [:index, :show]
  before_filter :find_or_initialize, :only => :show

  def index
    @ticket_types = @event.ticket_types
  end
  
  def show
    @purchases = @ticket_type.purchases.paginate(:all, :order => :created_at, :page => params[:page])
  end
  
  def new
    @ticket_type = TicketType.new
  end
  
  def destroy
    @ticket_type = TicketType.find(params[:id])
    @ticket_type.destroy
  end
  
  protected
  
    def find_event
      @event = Event.find(params[:event_id])
    end
  
    def host_required
      redirect_to dashboard_path and return unless @event.host.eql?(current_user)
    end
    
    def find_or_initialize
      @ticket_type = params[:id] ? @event.ticket_types.find(params[:id]) : @event.ticket_types.build
    end
  
end
