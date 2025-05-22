module SpreeFlutterwave
  module OrderDecorator
    def update_from_params(params, permitted_params, request_env = {})
      @updating_params = params

      if flutterwave_checkout?
        valid_payment.invalidate! if valid_payment.present? && !valid_payment_uses_flutterwave?
        update_from_params_using_flutterwave(params, permitted_params, request_env)
      else
        super(params, permitted_params, request_env)
      end
    end

    def update_from_params_using_flutterwave(params, permitted_params, request_env = {})
      success = false
      @updating_params = params
      run_callbacks :updating_from_params do
        attributes = if @updating_params[:order]
                       @updating_params[:order].permit(permitted_params).delete_if { |_k, v| v.nil? }
                     else
                       {}
                     end
        attributes[:payments_attributes].first[:request_env] = request_env if attributes[:payments_attributes]

        # Flutterwave Source and user present
        attributes = update_payment_with_flutterwave(attributes: attributes)
        # Flutterwave Source and user nill
        attributes = update_payment_with_flutterwave_for_guests(attributes: attributes)

        # Flutterwave Transaction
        update_flutterwave_with_transaction_id

        success = update(attributes)
        set_shipments_cost if shipments.any?
      end
      @updating_params = nil
      success
    end

    def flutterwave_checkout?
      # Only Rely on valid_payment when::
      # 1. If updating_params is nil?, which happens during all GET requests.
      # 2. For all POST requests for all stages other than the `payment` stage
      if @updating_params.nil? || @updating_params[:state] != 'payment'
        return valid_payment.payment_method.type == 'Spree::Gateway::Flutterwave' unless valid_payment.nil?

        return false
      end

      # Use params in the POST request for the `payement` stage.
      flutterwave_in_payment_attributes?
    end

    def valid_payment
      payments.valid.first
    end

    def confirmation_required?
      return true if flutterwave_checkout?

      super
    end

    private

    def update_payment_with_flutterwave(attributes:)
      payment_attributes = attributes[:payments_attributes].first if attributes[:payments_attributes].present?
      if flutterwave_checkout? && user.present? && payment_attributes.present?
        payment_method = store.payment_methods.find_by(type: 'Spree::Gateway::Flutterwave')
        flutterwave_checkout = ::SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: number, payment_method_id: payment_method.id).last

        if flutterwave_checkout.nil?
          flutterwave_checkout_attributes = {
            payment_method: payment_method,
            transaction_ref: number,
            user: user,
            status: 'pending'
          }
          flutterwave_checkout = ::SpreeFlutterwave::FlutterwaveCheckout.new(flutterwave_checkout_attributes)
          flutterwave_checkout.save
        end
        attributes[:payments_attributes].first[:source] = flutterwave_checkout
        attributes[:payments_attributes].first[:payment_method_id] = flutterwave_checkout.payment_method_id
        attributes[:payments_attributes].first.delete :source_attributes
      end
      attributes
    end

    def update_payment_with_flutterwave_for_guests(attributes:)
      payment_attributes = attributes[:payments_attributes].first if attributes[:payments_attributes].present?
      if flutterwave_checkout? && user.nil? && payment_attributes.present?
        payment_method = store.payment_methods.find_by(type: 'Spree::Gateway::Flutterwave')
        flutterwave_checkout = ::SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: number, payment_method_id: payment_method.id).last

        if flutterwave_checkout.nil?
          flutterwave_checkout_attributes = {
            payment_method: payment_method,
            transaction_ref: number,
            status: 'pending'
          }
          flutterwave_checkout = ::SpreeFlutterwave::FlutterwaveCheckout.new(flutterwave_checkout_attributes)
          flutterwave_checkout.save
        end

        attributes[:payments_attributes].first[:source] = flutterwave_checkout
        attributes[:payments_attributes].first[:payment_method_id] = flutterwave_checkout.payment_method_id
        attributes[:payments_attributes].first.delete :source_attributes
      end
      attributes
    end

    def update_flutterwave_with_transaction_id
      source_attributes = @updating_params[:source_attributes]
      if flutterwave_checkout? && source_attributes.present? && source_attributes[:flw_transaction_id]
        flw_transaction_id = source_attributes[:flw_transaction_id]
        flutterwave_checkout = ::SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: number).last
        flutterwave_checkout.transaction_id = flw_transaction_id
        flutterwave_checkout.save
      end
    end

    def flutterwave_gateway
      store.payment_methods.find_by(type: 'Spree::Gateway::Flutterwave')
    end

    def flutterwave_in_payment_attributes?
      return false if @updating_params.nil?

      payment_attributes = @updating_params[:order][:payments_attributes]
      return false if payment_attributes.nil?
      return false if payment_attributes.first[:payment_method_id].nil?

      return false if flutterwave_gateway.nil?

      flutterwave_gateway.id == payment_attributes.first[:payment_method_id].to_i
    end

    def valid_payment_uses_flutterwave?
      return false if valid_payment.nil?

      valid_payment.payment_method.type == 'Spree::Gateway::Flutterwave'
    end
  end
end

::Spree::Order.prepend(SpreeFlutterwave::OrderDecorator)
