module Spree
  module SpreeFlutterwave
    module PaymentsControllerDecorator
      def create
        invoke_callbacks(:create, :before)
        begin
          if @payment_method.store_credit?
            Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order)
            payments = @order.payments.store_credits.valid
          elsif @payment_method.is_a?(::SpreeFlutterwave::Gateway::Flutterwave)
            @payment ||= @order.payments.build(object_params)
            @payment.save
            payments = [@payment]
          else
            @payment ||= @order.payments.build(object_params)
            if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
              @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
            end
            @payment.save
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
                if payment.payment_method.is_a?(::SpreeFlutterwave::Gateway::Flutterwave) && @order.confirm?
                  payment.process!
                elsif @order.complete?
                  payment.process!
                end
              end
            end

            flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
            redirect_to spree.admin_order_payments_path(@order)
          else
            @payment ||= @order.payments.build(object_params)
            invoke_callbacks(:create, :fails)
            flash[:error] = Spree.t(:payment_could_not_be_created)
            render :new, status: :unprocessable_entity
          end
        rescue Spree::Core::GatewayError => e
          invoke_callbacks(:create, :fails)
          flash[:error] = e.message.to_s
          redirect_to new_admin_order_payment_path(@order)
        end
      end
    end
  end
end

::Spree::Admin::PaymentsController.prepend(::Spree::SpreeFlutterwave::PaymentsControllerDecorator)
