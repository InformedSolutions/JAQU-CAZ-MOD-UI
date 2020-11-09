# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'rails', '~> 6.0.3.3'

gem 'activerecord-nulldb-adapter'
gem 'aws-sdk-cognitoidentityprovider'
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
gem 'aws-sdk-secretsmanager'
gem 'bootsnap', require: false
gem 'devise'
gem 'haml'
gem 'httparty'
gem 'puma'
gem 'sdoc', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'webpacker'

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'haml-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'rails-controller-testing'
  gem 'rubocop-rails'
  gem 'scss_lint-govuk', require: false
  gem 'selenium-webdriver'
  gem 'show_me_the_cookies'
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'webdrivers'
  gem 'webmock'
end
