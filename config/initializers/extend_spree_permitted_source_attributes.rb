module Spree
  module PermittedAttributes
    source_attributes.push(:flw_transaction_id, :transaction_id, :transaction_ref)
    source_attributes.uniq!
  end
end
