module SpreeFlutterwave
  module Gateway
    class Flutterwave < Spree::Gateway
      preference :public_key, :string
      preference :secret_key, :string
      preference :encryption_key, :string

      def method_type
        'flutterwave'
      end

      def payment_source_class
        Spree::FlutterwaveCheckout
      end

      def source_required?
        false
      end

      def provider
        ::Flutterwave.new(preferred_public_key, preferred_secret_key, preferred_encryption_key)
      end

      def provider_class
        ::Flutterwave
      end
    end
  end
end
