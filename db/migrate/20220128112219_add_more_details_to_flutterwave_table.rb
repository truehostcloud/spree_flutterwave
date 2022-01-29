class AddMoreDetailsToFlutterwaveTable < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_flutterwave_checkouts, :currency, :string

    add_column :spree_flutterwave_checkouts, :amount, :decimal, precision: 10, scale: 2, default: '0.0', null: false
    add_column :spree_flutterwave_checkouts, :charged_amount, :decimal, precision: 10, scale: 2, default: '0.0', null: false
    add_column :spree_flutterwave_checkouts, :app_fee, :decimal, precision: 10, scale: 2, default: '0.0', null: false
    add_column :spree_flutterwave_checkouts, :merchant_fee, :decimal, precision: 10, scale: 2, default: '0.0', null: false
    add_column :spree_flutterwave_checkouts, :amount_settled, :decimal, precision: 10, scale: 2, default: '0.0', null: false

    add_column :spree_flutterwave_checkouts, :auth_model, :string
    add_column :spree_flutterwave_checkouts, :narration, :string

    add_column :spree_flutterwave_checkouts, :raw_Response, :jsonb
  end
end
