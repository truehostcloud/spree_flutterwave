module SpreeFlutterwave
  module PaymentMethodsControllerDecorator
    def create
      payment_method_type = params[:payment_method].delete(:type)
      @payment_method = payment_method_type.constantize.new(payment_method_params)
      @object = @payment_method
      set_current_store
      @payment_method.display_on = 'front_end' if payment_method_type == 'SpreeFlutterwave::Gateway::Flutterwave'
      invoke_callbacks(:create, :before)
      if @payment_method.save
        invoke_callbacks(:create, :after)
        flash[:success] = Spree.t(:successfully_created, resource: Spree.t(:payment_method))
        redirect_to spree.edit_admin_payment_method_path(@payment_method)
      else
        invoke_callbacks(:create, :fails)
        respond_with(@payment_method, status: :unprocessable_entity)
      end
    end

    def update
      invoke_callbacks(:update, :before)
      payment_method_type = params[:payment_method].delete(:type)
      if @payment_method['type'].to_s != payment_method_type
        @payment_method.update_columns(
          type: payment_method_type,
          updated_at: Time.current
        )
        @payment_method = scope.find(params[:id])
      end

      attributes = payment_method_params.merge(preferences_params)
      attributes.each do |k, _v|
        attributes.delete(k) if k.include?('password') && attributes[k].blank?
      end

      attributes[:display_on] = 'front_end' if payment_method_type == 'SpreeFlutterwave::Gateway::Flutterwave'

      if @payment_method.update(attributes)
        set_current_store
        invoke_callbacks(:update, :after)
        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:payment_method))
        redirect_to spree.edit_admin_payment_method_path(@payment_method)
      else
        invoke_callbacks(:update, :fails)
        respond_with(@payment_method, status: :unprocessable_entity)
      end
    end
  end
end

Spree::Admin::PaymentMethodsController.prepend(SpreeFlutterwave::PaymentMethodsControllerDecorator)
