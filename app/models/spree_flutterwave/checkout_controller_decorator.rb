module SpreeFlutterwave
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :load_flutterave_payment_source
    end

    def load_flutterave_payment_source
      @flutterwave_payment_source = SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: @order.number).last
    end
  end
end

::Spree::CheckoutController.prepend(SpreeFlutterwave::CheckoutControllerDecorator)
