module SpreeFlutterwave
  module Gateway
    class Flutterwave < Spree::Gateway
      def method_type
        'flutterwave_payment_method_ui'
      end
    end
  end
end
