Rails.application.config.assets.precompile << 'flutterwave_manifest.js'

Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
