require_dependency 'spree_flutterwave/gateway/flutterwave_response'
require_dependency 'spree_flutterwave/gateway/flutterwave_errors'

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

      def auto_capture?
        true
      end

      def supports?(source)
        source.instance_of?(payment_source_class)
      end

      def provider
        ::Flutterwave.new(preferred_public_key, preferred_secret_key, preferred_encryption_key, production?)
      end

      def provider_class
        ::Flutterwave
      end

      def authorize(money_in_cents, source, gateway_options)
        purchase(money_in_cents, source, gateway_options)
      end

      def purchase(_money_in_cents, source, _gateway_options)
        return ActiveMerchant::Billing::Response.new(false, 'Flutterwave: Transaction Id is missing') if source.transaction_id.nil?

        tx = Transactions.new(provider)
        begin
          res = verify(tx, source)
          SpreeFlutterwave::Gateway::FlutterwaveResponse.new(res)
        rescue ::FlutterwaveServerError => e
          handle_flutterwave_api_errors(e)
        rescue SpreeFlutterwave::Gateway::FlutterwaveErrors::PaymentDoesNotBelongToOrder => e
          ActiveMerchant::Billing::Response.new(false, e.message)
        end
      end

      private

      def verify(transaction, source)
        res = transaction.verify_transaction(source.transaction_id)
        body = JSON.parse res.body, symbolize_names: true
        tx_ref = body[:data][:tx_ref]
        raise SpreeFlutterwave::Gateway::FlutterwaveErrors::PaymentDoesNotBelongToOrder unless tx_ref == source.transaction_ref

        mark_source_as_verified(source)
        res
      end

      def mark_source_as_verified(source)
        source.status = 'verified'
        source.save
      end

      def handle_flutterwave_api_errors(error)
        body = JSON.parse error.response.body, symbolize_names: true
        message = "Flutterwave Error: #{body[:message]}"
        ActiveMerchant::Billing::Response.new(false, message)
      end

      def production?
        !preferred_test_mode
      end
    end
  end
end
