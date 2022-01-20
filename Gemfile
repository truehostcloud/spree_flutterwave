source 'https://rubygems.org'

spree_opts = '>= 4.4.0.rc1'
gem 'deface'
gem 'flutterwave_sdk', github: 'Flutterwave/Flutterwave-Ruby-v3', branch: 'master'
gem 'spree', spree_opts

group :test do
  gem 'rails-controller-testing'
end

group :development do
  gem 'htmlbeautifier'
  gem 'rcodetools', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'solargraph', require: false
end

gemspec
