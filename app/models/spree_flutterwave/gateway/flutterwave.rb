require_relative 'flutterwave_response'
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

      def auto_capture?
        true
      end

      def create_profile(payment)
        payment
      end

      def supports?(source)
        source.instance_of?(payment_source_class)
      end

      def purchase(_money_in_cents, source, _gateway_options)
        ActiveMerchant::Billing::Response.new(false, 'Flutterwave: Transaction Id is missing') if source.transaction_id.nil?
        tx = Transactions.new(provider)
        begin
          res = tx.verify_transaction(source.transaction_id)
          SpreeFlutterwave::Gateway::FlutterwaveResponse.new(res)
        rescue ::FlutterwaveServerError => e
          ActiveMerchant::Billing::Response.new(false, 'Flutterwave: XXX', { message: e })
        end
      end

      def authorize(money_in_cents, source, gateway_options)
        purchase(money_in_cents, source, gateway_options)
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
