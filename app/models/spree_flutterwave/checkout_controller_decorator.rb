module SpreeFlutterwave
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :load_flutterave_payment_source
    end

    def update
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(spree.checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to spree.checkout_state_path(@order.state)
        end
      else
        render :edit
      end
    end

    def load_flutterave_payment_source
      @flutterwave_payment_source = SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: @order.number).last
    end
  end
end

::Spree::CheckoutController.prepend(SpreeFlutterwave::CheckoutControllerDecorator)
