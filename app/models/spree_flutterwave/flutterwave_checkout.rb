class SpreeFlutterwave::Gateway::FlutterwaveCheckout < ActiveRecord::Base
  has_one :payment, as: :source, class_name: 'Spree::Payment'
  has_one :order, through: :payment
end
