module SpreeFlutterwave
  class FlutterwaveCheckout < ApplicationRecord
    self.table_name = 'spree_flutterwave_checkouts'

    attr_accessor :imported

    has_one :payment, as: :source, class_name: 'Spree::Payment', dependent: :destroy
    has_one :order, through: :payment, dependent: :destroy
    belongs_to :payment_method, class_name: 'Spree::PaymentMethod'

    validates :transaction_id, presence: true
    validates :transaction_ref, presence: true
    validates :status, presence: true
  end
end
