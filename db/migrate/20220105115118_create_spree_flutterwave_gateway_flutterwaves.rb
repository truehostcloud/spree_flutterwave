class CreateSpreeFlutterwaveGatewayFlutterwaves < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_flutterwave_checkouts do |t|
      t.string :transaction_id, index: true
      t.string :transaction_ref, index: true

      t.timestamps
    end
  end
end
