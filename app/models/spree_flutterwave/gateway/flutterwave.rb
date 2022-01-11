module SpreeFlutterwave
  module Gateway
    class Flutterwave < Spree::Gateway
      def method_type
        'flutterwave'
      end
    end
  end
end
