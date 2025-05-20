module Spree
  module Gateway
    class FlutterwaveResponse < ActiveMerchant::Billing::Response
      def initialize(httparty_response)
        # initialize(success, message, params = {}, options = {})
        super(did_succeed?(httparty_response.code), httparty_response.body)
      end

      private

      def did_succeed?(code)
        [200, 201].include?(code.to_i)
      end
    end
  end
end
