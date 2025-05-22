module SpreeFlutterwave
  module PaymentMethod
    class FlutterwaveCheckout < ::Spree::PaymentMethod
      def payment_source_class
        ::SpreeFlutterwave::FlutterwaveCheckout
      end
    end
  end
end
