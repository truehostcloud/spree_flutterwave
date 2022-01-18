module SpreeFlutterwave
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :load_flutterave_payment_sources
    end

    def load_flutterave_payment_sources
      return unless try_spree_current_user.respond_to?(:flutterwave_checkout)

      @flutterwave_payment_sources = try_spree_current_user.flutterwave_checkout(@order)
    end
  end
end

::Spree::CheckoutController.prepend(SpreeFlutterwave::CheckoutControllerDecorator)
