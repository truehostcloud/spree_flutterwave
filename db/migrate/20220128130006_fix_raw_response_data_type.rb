class FixRawResponseDataType < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      change_table :spree_flutterwave_checkouts do |t|
        dir.up do
          t.json :raw_response, :json
        end

        dir.down do
          t.jsonb :raw_response
        end
      end
    end
  end
end
