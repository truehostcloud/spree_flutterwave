Spree::Core::Engine.add_routes do
  post '/flutterwave/payment', controller: 'spree_flutterwave/flutterwave', action: 'record_payment'
end
