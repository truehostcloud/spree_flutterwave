Spree::Core::Engine.add_routes do
  post '/flutterwave/payment', controller: :flutterwave, action: :index
end
