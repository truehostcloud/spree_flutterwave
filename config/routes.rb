Spree::Core::Engine.add_routes do
  post '/flutterwave/callback', controller: 'spree_flutterwave/flutterwave', action: :index
end
