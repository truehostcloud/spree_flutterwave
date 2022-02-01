class MakeTransactionIdAndRefUnique < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      change_table :spree_flutterwave_checkouts do |t|
        dir.up do
          t.bigint :transaction_id, index: { unique: true }
          t.string :transaction_ref, index: { unique: true }
        end

        dir.down do
          t.bigint :transaction_id
          t.string :transaction_ref
        end
      end
    end
  end
end
