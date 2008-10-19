ActionController::Routing::Routes.draw do |map|

  map.home '', :controller => 'home'
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login  'login', :controller => 'session', :action => 'new'
  map.dashboard 'dashboard', :controller => 'users', :action => 'show'
  map.logout 'logout', :controller => 'session', :action => 'destroy'
  map.about 'about', :controller => 'info', :action => 'about'
  map.open_id_complete 'session', :controller => "session", :action => "create", :requirements => { :method => :get }
  
  map.resources :users, :tickets, :ticket_types, :purchases
  map.resources :events, :member => { :share => :get } do |events|
    events.resources :ticket_types, :tickets, :news_items
  end
  map.resource  :session, :controller => 'session'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
