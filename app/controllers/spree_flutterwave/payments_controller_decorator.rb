module SpreeFlutterwave
  module PaymentsControllerDecorator
    def self.prepended(base); end

    def create
      invoke_callbacks(:create, :before)

      begin
        if @payment_method.store_credit?
          Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order)
          payments = @order.payments.store_credits.valid
        else
          @payment ||= @order.payments.build(object_params)
          if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
            @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
          elsif @payment.payment_method.source_required? && @payment.payment_source.is_a?(SpreeFlutterwave::Gateway::Flutterwave)
            flutterwave_checkout = SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: @order.number).last

            if flutterwave_checkout.nil?
              flutterwave_checkout_attributes = {
                payment_method: Spree::PaymentMethod.find_by(type: 'SpreeFlutterwave::Gateway::Flutterwave'),
                transaction_ref: @order.number,
                status: 'pending'
              }
              flutterwave_checkout_attributes[:user] = @order.user if @order.user.present?
              flutterwave_checkout = SpreeFlutterwave::FlutterwaveCheckout.new(flutterwave_checkout_attributes)
              flutterwave_checkout.save
            end

            @payment.source = flutterwave_checkout
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

          saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }

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

::Spree::Admin::PaymentsController.prepend(SpreeFlutterwave::PaymentsControllerDecorator)
