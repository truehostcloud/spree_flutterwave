module SpreeFlutterwave
  module PaymentsControllerDecorator
    def self.prepended(base); end

    def create
      invoke_callbacks(:create, :before)

      begin
        if @payment_method.store_credit?
          Spree::Dependencies.checkout_add_store_credit_service.constantize.call(order: @order)
          payments = @order.payments.store_credits.valid
        else
          @payment ||= @order.payments.build(object_params)
          if @payment.payment_method.source_required? && params[:card].present? && params[:card] != 'new'
            @payment.source = @payment.payment_method.payment_source_class.find_by(id: params[:card])
          elsif @payment.payment_method.source_required? && @payment.payment_source.is_a?(SpreeFlutterwave::Gateway::Flutterwave)
            @payment.source = flutterwave_checkout
            payment_link = generate_flutterwave_link
          end

          @payment.save
          payments = [@payment]
        end

        if payments && (saved_payments = payments.select(&:persisted?)).any?
          invoke_callbacks(:create, :after)
          # Transition order as far as it will go.
          while @order.next; end
          # If "@order.next" didn't trigger payment processing already (e.g. if the order was
          # already complete) then trigger it manually now

          saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }

          flash[:success] = flash_message_for(saved_payments.first, :successfully_created)
          redirect_to spree.admin_order_payments_path(@order)
        else
          @payment ||= @order.payments.build(object_params)
          invoke_callbacks(:create, :fails)
          flash[:error] = Spree.t(:payment_could_not_be_created)
          render :new, status: :unprocessable_entity
        end
      rescue Spree::Core::GatewayError => e
        invoke_callbacks(:create, :fails)
        flash[:error] = e.message.to_s
        redirect_to new_admin_order_payment_path(@order)
      end
    end

    def flutterwave_checkout
      checkout = SpreeFlutterwave::FlutterwaveCheckout.where(transaction_ref: @order.number).last
      if checkout.nil?
        flutterwave_checkout_attributes = {
          payment_method: Spree::PaymentMethod.find_by(type: 'SpreeFlutterwave::Gateway::Flutterwave'),
          transaction_ref: @order.number,
          status: 'pending'
        }
        flutterwave_checkout_attributes[:user] = @order.user if @order.user.present?
        checkout = SpreeFlutterwave::FlutterwaveCheckout.new(flutterwave_checkout_attributes)
        checkout.save
      end
      checkout
    end

    def generate_flutterwave_link
      return unless @payment.payment_source.is_a?(SpreeFlutterwave::FlutterwaveCheckout)

      payload = {
        tx_ref: @order.number,
        amount: @order.total,
        currency: @order.currency,
        redirect_url: 'https://webhook.site/9d0b00ba-9a69-44fa-a43d-a82c33c36fdc',
        payment_options: 'account,card,banktransfer,mpesa,mobilemoneyrwanda,mobilemoneyzambia,',
        customer: {
          email: @order.email
        },
        customizations: {
          title: current_store.name,
          logo: 'https://olitt.b-cdn.net/static/media/olitt-logo-secondary.de8fee27.svg'
        }
      }

      provider = @payment.payment_method.provider

      begin
        response = HTTParty.post('https://api.flutterwave.com/v3/payments', {
                                   body: payload.to_json,
                                   headers: {
                                     'Content-Type' => 'application/json',
                                     'Authorization' => "Bearer #{provider.secret_key}"
                                   }
                                 })

        raise FlutterwaveServerError.new(response), "HTTP Code #{response.code}: #{response.body}" unless response.code == 200 || response.code == 201
      end
      res = JSON.parse response, symbolize_names: true
      res[:data][:link]
    end
  end
end

::Spree::Admin::PaymentsController.prepend(SpreeFlutterwave::PaymentsControllerDecorator)
