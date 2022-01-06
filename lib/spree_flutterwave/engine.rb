module SpreeFlutterwave
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_flutterwave'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_flutterwave.environment', before: :load_config_initializers do |_app|
      SpreeFlutterwave::Config = SpreeFlutterwave::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)

    initializer 'spree_flutterwave.payment_methods', after: 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << SpreeFlutterwave::Gateway::Flutterwave
    end
  end
end
