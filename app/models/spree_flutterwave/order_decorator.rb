module SpreeFlutterwave
  module OrderDecorator
    def update_from_params(params, permitted_params, request_env = {})
      success = false
      @updating_params = params
      run_callbacks :updating_from_params do
        # Set existing card after setting permitted parameters because
        # rails would slice parameters containing ruby objects, apparently
        existing_card_id = @updating_params[:order] ? @updating_params[:order].delete(:existing_card) : nil
        # don't search for card if, flutterwave is selected
        existing_card_id = flutterwave_checkout? ? nil? : existing_card_id

        attributes = if @updating_params[:order]
                       @updating_params[:order].permit(permitted_params).delete_if { |_k, v| v.nil? }
                     else
                       {}
                     end

        if existing_card_id.present?
          credit_card = ::Spree::CreditCard.find existing_card_id
          raise Core::GatewayError, Spree.t(:invalid_credit_card) if credit_card.user_id != user_id || credit_card.user_id.blank?

          credit_card.verification_value = params[:cvc_confirm] if params[:cvc_confirm].present?

          attributes[:payments_attributes].first[:source] = credit_card
          attributes[:payments_attributes].first[:payment_method_id] = credit_card.payment_method_id
          attributes[:payments_attributes].first.delete :source_attributes
        end

        attributes[:payments_attributes].first[:request_env] = request_env if attributes[:payments_attributes]
        payment_attributes = attributes[:payments_attributes].first if attributes[:payments_attributes].present?

        # Flutterwave
        if flutterwave_checkout? && payment_attributes.present?
          flutterwave_checkout = SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: number).last

          if flutterwave_checkout.present?
            if flutterwave_checkout.user_id != user_id || flutterwave_checkout.user_id.blank?
              raise Core::GatewayError, Spree.t(:invalid_flutterwave_checkout)
            end

            payment_attributes[:source] = flutterwave_checkout
          end

        end

        success = update(attributes)
        set_shipments_cost if shipments.any?
      end

      @updating_params = nil
      success
    end

    def flutterwave_checkout?
      return false if @updating_params[:order][:payments_attributes].nil?
      return false if @updating_params[:order][:payments_attributes].first[:payment_method_id].nil?

      gateway = Spree::PaymentMethod.find_by(type: 'SpreeFlutterwave::Gateway::Flutterwave')
      gateway.id == @updating_params[:order][:payments_attributes].first[:payment_method_id].to_i
    end
  end
end

::Spree::Order.prepend(SpreeFlutterwave::OrderDecorator)
