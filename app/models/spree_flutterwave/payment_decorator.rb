module SpreeFlutterwave
  module PaymentDecorator
    def handle_response(response, success_state, _failure_state)
      record_response(response)

      if response.success?
        unless response.authorization.nil?
          self.response_code = response.authorization
          self.avs_response = response.avs_result['code']

          if response.cvv_result
            self.cvv_response_code = response.cvv_result['code']
            self.cvv_response_message = response.cvv_result['message']
          end
        end
        send("#{success_state}!")
      else
        send(:pending)
        gateway_error(response)
      end
    end
  end
end

Spree::Payment.prepend(SpreeFlutterwave::PaymentDecorator)

module PaymentServiceDecorator
  def failure(value, error = nil)
    raise Exception, value
    error = value.errors if error.nil? && value.respond_to?(:errors)
    Result.new(false, value, ResultError.new(error))
  end
end

Spree::ServiceModule::Base.prepend(PaymentServiceDecorator)
