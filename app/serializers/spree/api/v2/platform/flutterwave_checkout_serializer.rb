module Spree
  module Api
    module V2
      module Platform
        class FlutterwaveCheckoutSerializer < BaseSerializer
          set_type :flutterwave_checkout

          attributes :transaction_id, :transaction_ref, :status, :currency, :amount, :charged_amount, :app_fee, :merchant_fee, :amount_settled,
                     :auth_model, :narration, :created_at, :updated_at

          belongs_to :payment_method
          belongs_to :user
        end
      end
    end
  end
end
