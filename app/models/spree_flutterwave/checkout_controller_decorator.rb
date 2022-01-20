module SpreeFlutterwave
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :load_flutterave_payment_method
      base.helper_method :flutterwave_chosen?
    end

    def load_flutterave_payment_method
      @flutterwave_payment_method = Spree::PaymentMethod.find_by(type: 'SpreeFlutterwave::Gateway::Flutterwave')
    end

    def flutterwave_chosen?
      @order.valid_payment.payment_method.type == 'SpreeFlutterwave::Gateway::Flutterwave'
    end
  end
end

::Spree::CheckoutController.prepend(SpreeFlutterwave::CheckoutControllerDecorator)
