ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  
  map.connect '', :controller => 'links'
  
  map.connect 'tinythomas/remote', :controller => 'links', :action => 'create'
  
  map.connect 'about', :controller => 'links', :action => 'about'
  map.connect 'api', :controller => 'links', :action => 'api'
  map.connect 'report-abuse', :controller => 'links', :action => 'report'
  map.connect 'home', :controller => 'links', :action => 'index'  

  map.resources :links, :name_prefix => 'api_', :path_prefix => 'api', :controller => 'api/links'  
  
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  
  map.connect ':token/oc', :controller => 'links', :action => 'redirect', :site=>'oc'
  map.connect ':token/gt', :controller => 'links', :action => 'redirect', :site=>'gt'
  map.connect ':token', :controller => 'links', :action => 'redirect'
  
end
