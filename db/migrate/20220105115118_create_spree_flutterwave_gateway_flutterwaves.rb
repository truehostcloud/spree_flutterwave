class CreateSpreeFlutterwaveGatewayFlutterwaves < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_flutterwave_checkouts, if_not_exists: true do |t|
      t.bigint :transaction_id, index: true
      t.string :transaction_ref, index: true
      t.bigint :payment_method_id, index: true
      t.bigint :user_id, index: true
      t.string :status

      t.timestamps
    end
  end
end
