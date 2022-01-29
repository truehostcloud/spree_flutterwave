class FixRawResponseDataType < ActiveRecord::Migration[6.1]
  def change
    change_column :spree_flutterwave_checkouts, :raw_response, :json
  end
end
