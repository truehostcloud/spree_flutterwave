module Spree
  module Flutterwave
    module CheckoutControllerDecorator
      def self.prepended(base)
        base.before_action :load_flutterave_payment_method
        base.helper_method :flutterwave_chosen?
      end

      def load_flutterave_payment_method
        @flutterwave_payment_method = @order.store.payment_methods.find_by(type: 'Spree::Gateway::Flutterwave')
      end

      def flutterwave_chosen?
        return @order.valid_payment.payment_method.type == 'Spree::Gateway::Flutterwave' if @order.valid_payment.present?

        false
      end
    end
  end
end

::Spree::CheckoutController.prepend(::Spree::Flutterwave::CheckoutControllerDecorator)
