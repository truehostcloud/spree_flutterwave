module Spree
  module SpreeFlutterwave
    module PaymentsControllerDecorator
      FLUTTERWAVE_SOURCE_ATTRIBUTES = %i[
        transaction_ref
        transaction_id
        status
        currency
        amount
        charged_amount
        app_fee
        merchant_fee
        amount_settled
        payment_type
        auth_model
        narration
        raw_response
      ].freeze

      private

      def load_data
        super
        @payment_method = selected_payment_method_for_admin_payment
      end

      def object_params
        if params[:payment].present? && params[:payment_source].present?
          source_params = params[:payment_source][params[:payment][:payment_method_id]]
          params[:payment][:source_attributes] = source_params if source_params.present?
        end

        params.require(:payment).permit(
          :amount,
          :payment_method_id,
          :payment_method,
          source_attributes: permitted_source_attributes + FLUTTERWAVE_SOURCE_ATTRIBUTES
        )
      end

      def selected_payment_method_for_admin_payment
        return @payment.payment_method if defined?(@payment) && @payment&.payment_method.present?
        return @payment_methods.first if params[:payment].blank? || params[:payment][:payment_method_id].blank?

        payment_method_id = params[:payment][:payment_method_id].to_s
        @payment_methods.find { |payment_method| payment_method.id.to_s == payment_method_id } || @payment_methods.first
      end

      public

      def create
        invoke_callbacks(:create, :before)
        begin
          if @payment_method.store_credit?
            Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order)
            payments = @order.payments.store_credits.valid
          else
            @payment = @object ||= model_class.new(order: @order)
            @payment.attributes = object_params
            @payment.build_source

            if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
              @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
            end

            @payment.save!
            payments = [@payment]
          end

          if payments && (saved_payments = payments.select(&:persisted?)).any?
            invoke_callbacks(:create, :after)

            # Transition order as far as it will go.
            while @order.next; end
            # If "@order.next" didn't trigger payment processing already (e.g. if the order was
            # already complete) then trigger it manually now
            saved_payments.each do |payment|
              if payment.reload.checkout?
                if payment.payment_method.is_a?(::Spree::Gateway::Flutterwave) && @order.confirm?
                  payment.process!
                elsif @order.complete?
                  payment.process!
                end
              end
            end

            flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
            redirect_to location_after_save
          else
            @payment ||= @object || model_class.new(order: @order)
            invoke_callbacks(:create, :fails)
            flash[:error] = Spree.t(:payment_could_not_be_created)
            render :new, status: :unprocessable_entity
          end
        rescue Spree::Core::GatewayError => e
          invoke_callbacks(:create, :fails)
          flash[:error] = e.message.to_s
          redirect_to new_admin_order_payment_path(@order)
        rescue ActiveRecord::RecordInvalid
          invoke_callbacks(:create, :fails)
          flash[:error] = @payment.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      end
    end
  end
end

::Spree::Admin::PaymentsController.prepend(::Spree::SpreeFlutterwave::PaymentsControllerDecorator)
