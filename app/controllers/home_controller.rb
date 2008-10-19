class HomeController < ApplicationController
  def index
    @events = Event.find_upcoming
  end
end
