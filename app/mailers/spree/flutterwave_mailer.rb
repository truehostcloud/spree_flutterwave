module Spree
  class FlutterwaveMailer < ::Spree::BaseMailer
    def send_payment_link(order)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = ''
      mail(to: @order.email, from: from_address, subject: subject, store_url: current_store.url, reply_to: reply_to_address,
           template_name: 'send_payment_link')
    end

    def reply_to_address
      current_store.mail_from_address
    end
  end
end
