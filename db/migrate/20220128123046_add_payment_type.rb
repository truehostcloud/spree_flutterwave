class AddPaymentType < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_flutterwave_checkouts, :payment_type, :string, if_not_exists: true
  end
end
