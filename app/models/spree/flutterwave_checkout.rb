module Spree
  class FlutterwaveCheckout < ApplicationRecord
    has_one :payment, as: :source, class_name: 'Spree::Payment', dependent: :destroy
    has_one :order, through: :payment, dependent: :destroy
    belongs_to :payment_method
  end
end
