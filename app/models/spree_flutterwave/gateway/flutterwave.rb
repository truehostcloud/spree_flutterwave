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

      def provider
        ::Flutterwave.new(preferred_public_key, preferred_secret_key, preferred_encryption_key, 'https://ravesandboxapi.flutterwave.com')
      end

      def provider_class
        ::Flutterwave
      end

      def authorize(_money_in_cents, _source, _gateway_options)
        tx = Transactions.new(provider)
        # tx.verify_transaction(source.transaction_id)
        ActiveMerchant::Billing::Response.new(true, 'Flutterwave Gateway: Forced Success', { message: 'Flutterwave Gateway: Forced success' },
                                              test: true)
      end
    end
  end
end
