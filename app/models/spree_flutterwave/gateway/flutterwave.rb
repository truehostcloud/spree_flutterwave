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
        false
      end

      def payment_profiles_supported?
        true
      end

      def create_profile(payment)
        # raise Exception, payment.source
      end

      def provider
        ::Flutterwave.new(preferred_public_key, preferred_secret_key, preferred_encryption_key, true)
      end

      def provider_class
        ::Flutterwave
      end

      def http
        uri = URI(provider.url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http
      end

      def authorize(_money_in_cents, _source, _gateway_options)
        uri = URI(provider.url)
        uri_path = "#{uri.path}/payments"
        headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{preferred_secret_key}" }
        req = Net::HTTP::Post.new(uri_path, headers)

        payload = {
          'card_number' => '5531886652142950',
          'cvv' => '564',
          'expiry_month' => '09',
          'expiry_year' => '22',
          'currency' => 'NGN',
          'amount' => '10',
          'email' => 'xxxxxxxxxx@gmail.com',
          'fullname' => 'Test Name',
          'tx_ref' => 'MC-3243e-if-12',
          'redirect_url' => 'https://webhook.site/399'
        }

        res = http.request(req, payload.to_json)

        json = JSON.parse(res.body)

        respond_to json['data']['link']

        # tx = Transactions.new(provider)
        # # tx.verify_transaction(source.transaction_id)
        # ActiveMerchant::Billing::Response.new(true, 'Flutterwave Gateway: Forced Success', { message: 'Flutterwave Gateway: Forced success' },
        #                                       test: true)
      end
    end
  end
end
