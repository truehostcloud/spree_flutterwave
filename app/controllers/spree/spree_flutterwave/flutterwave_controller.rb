module Spree
  module SpreeFlutterwave
    class FlutterwaveController < ActionController::API
      def record_payment
        transaction_id, tx_ref, amount, currency, charged_amount, app_fee, merchant_fee, auth_model, narration, status, payment_type = permitted_attributes.values_at(:id,
                                                                                                                                                                      :tx_ref, :amount, :currency, :charged_amount, :app_fee, :merchant_fee, :auth_model, :narration, :status, :payment_type)

        order = Spree::Order.find_by(number: tx_ref)

        mailer = ::Spree::FlutterwaveMailer.new

        mail = mailer.send_payment_link(order)

        mail.deliver

        return render json: order

        raise ActionController::ParameterMissing, :transaction_id if transaction_id.nil?
        raise ActionController::ParameterMissing, :tx_ref if tx_ref.nil?
        raise ActionController::ParameterMissing, :amount if amount.nil?
        raise ActionController::ParameterMissing, :currency if currency.nil?
        raise ActionController::ParameterMissing, :charged_amount if charged_amount.nil?
        raise ActionController::ParameterMissing, :app_fee if app_fee.nil?
        raise ActionController::ParameterMissing, :merchant_fee if merchant_fee.nil?
        raise ActionController::ParameterMissing, :auth_model if auth_model.nil?
        raise ActionController::ParameterMissing, :narration if narration.nil?
        raise ActionController::ParameterMissing, :status if status.nil?
        raise ActionController::ParameterMissing, :payment_type if payment_type.nil?

        checkout = ::SpreeFlutterwave::FlutterwaveCheckout.find_by(transaction_ref: tx_ref)
        checkout.transaction_id = transaction_id
        checkout.status = status
        checkout.save

        return render_errors(checkout.errors) unless checkout.save

        render json: { message: 'flutterwave transation rescorded successfully' }, status: :ok, content_type: 'application/vnd.api+json'
      end

      def render_errors(errors)
        # json = if errors.is_a?(ActiveModel::Errors)
        #          { error: errors.full_messages.to_sentence, errors: errors.messages }
        #        elsif errors.is_a?(Struct)
        #          { error: errors.to_s, errors: errors.to_h }
        #        else
        #          { error: errors }
        #  end
        json = case errors.class
               when ActiveModel::Errors
                 { error: errors.full_messages.to_sentence, errors: errors.messages }
               when Struct
                 { error: errors.to_s, errors: errors.to_h }
               else
                 { error: errors }
               end

        render json: json, status: :unprocessable_entity, content_type: 'application/vnd.api+json'
      end

      def permitted_attributes
        payload.permit(%i[id tx_ref amount currency charged_amount app_fee merchant_fee auth_model narration status payment_type])
      end

      def payload
        params.require(:data)
      end
    end
  end
end
