module Spree
    module CheckoutControllerDecorator
        def xxx
            "XXXX"
        end
    end
end

::Spree::CheckoutController.prepend(Spree::CheckoutControllerDecorator)