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
        SpreeFlutterwave::FlutterwaveCheckout
      end

      def source_required?
        true
      end

      def payment_profiles_supported?
        true
      end

      def create_profile(payment)
        payment
      end

      def supports?(source)
        source.instance_of?(payment_source_class)
      end

      def capture(_money_in_cents, _source, _gateway_options)
        raise Exception, 'Capture'
      end

      def purchase(_money_in_cents, _source, _gateway_options)
        raise Exception, 'Purchase'
      end

      def authorize(_money_in_cents, _source, _gateway_options)
        raise Exception, _gateway_options
      end

      def provider
        ::Flutterwave.new(preferred_public_key, preferred_secret_key, preferred_encryption_key, true)
      end

      def provider_class
        ::Flutterwave
      end
    end
  end
end
