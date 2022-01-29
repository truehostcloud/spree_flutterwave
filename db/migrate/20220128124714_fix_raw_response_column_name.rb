class FixRawResponseColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :spree_flutterwave_checkouts, :raw_Response, :raw_response
  end
end
