Rails.application.config.after_initialize do
  Rails.application.config.spree.payment_methods << SpreeFlutterwave::Gateway
end