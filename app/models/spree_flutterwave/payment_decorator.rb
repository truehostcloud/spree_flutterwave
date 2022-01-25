module SpreeFlutterwave
  module PaymentDecorator
    def handle_payment_preconditions
      raise ArgumentError, 'handle_payment_preconditions must be called with a block' unless block_given?

      if payment_method&.source_required?
        if source
          unless processing?
            if payment_method.supports?(source) || token_based?
              yield
            else
              invalidate!
              raise Core::GatewayError, Spree.t(:payment_method_not_supported)
            end
          end
        else
          raise Core::GatewayError, Spree.t(:payment_processing_failed)
        end
      end
    end

    def gateway_action(source, action, success_state)
      protect_from_connection_error do
        response = payment_method.send(action, money.amount_in_cents,
                                       source,
                                       gateway_options)
        handle_response(response, success_state, :failure)
      end
    end

    def invalidate_old_payments
      # invalid payment or store_credit payment shouldn't invalidate other payment types
      return if has_invalid_state? || store_credit?

      order.payments.with_state('checkout').where.not(id: id).each do |payment|
        # raise Exception, payment
        payment.invalidate! unless payment.store_credit?
      end
    end
  end
end

::Spree::Payment.prepend(SpreeFlutterwave::PaymentDecorator)
