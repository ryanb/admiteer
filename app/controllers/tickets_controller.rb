class TicketsController < ApplicationController
  
  before_filter :find_event, :except => :show
  before_filter :find_or_initialize
  
  protected
  
    def find_event
      @event = Event.find(params[:event_id])
    end
  
    def find_or_initialize
      @ticket = params[:id] ? Ticket.find(params[:id]) : @event.tickets.build
    end
  
end

