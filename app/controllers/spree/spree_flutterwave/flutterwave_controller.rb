module Spree
  module SpreeFlutterwave
    class FlutterwaveController < ActionController::API
      include ::ActionController::Redirecting

      def index
        transaction_id, tx_ref, status = permitted_attributes.values_at(:transaction_id, :tx_ref, :status)

        raise ActionController::ParameterMissing, :transaction_id if transaction_id.nil?
        raise ActionController::ParameterMissing, :tx_ref if tx_ref.nil?

        checkout = ::SpreeFlutterwave::FlutterwaveCheckout.find_by(transaction_ref: tx_ref)
        checkout.transaction_id = transaction_id
        checkout.status = status
        checkout.save

        return render_errors(checkout.errors) unless checkout.save

        render json: { message: 'flutterwave transation rescorded successfully' }, status: :ok, content_type: 'application/vnd.api+json'
      end

      def render_errors(errors)
        json = if errors.is_a?(ActiveModel::Errors)
                 { error: errors.full_messages.to_sentence, errors: errors.messages }
               elsif errors.is_a?(Struct)
                 { error: errors.to_s, errors: errors.to_h }
               else
                 { error: errors }
               end

        render json: json, status: :unprocessable_entity, content_type: 'application/vnd.api+json'
      end

      def permitted_attributes
        params.permit(%i[transaction_id tx_ref status])
      end
    end
  end
end
