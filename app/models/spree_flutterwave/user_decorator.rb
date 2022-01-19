module Spree
  module UserDecorator
    def self.prepended(base)
      base.has_many :flutterwave_checkouts, foreign_key: :user_id, class_name: 'SpreeFlutterwave::FlutterwaveCheckout', dependent: :destroy
    end

    def flutterwave_checkout(order)
      flutterwave_checkouts.where(transaction_ref: order.number).last
    end
  end
end

::Spree::User.prepend(Spree::UserDecorator)
