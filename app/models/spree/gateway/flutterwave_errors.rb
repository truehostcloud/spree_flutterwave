module Spree
  module Gateway
    module FlutterwaveErrors
      class PaymentDoesNotBelongToOrder < StandardError
        attr_accessor :message

        def initialize
          super
          @message = 'Flutterwave Error: This order is not associated with the provided Flutterwave transaction. Please contact support.'
        end
      end
    end
  end
end
