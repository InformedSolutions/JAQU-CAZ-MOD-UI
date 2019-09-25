# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 6.0'

gem 'activerecord-nulldb-adapter'
gem 'aws-sdk-cognitoidentityprovider'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'brakeman'
gem 'bundler-audit'
gem 'devise'
gem 'haml'
gem 'httparty'
gem 'logstash-logger'
gem 'puma'
gem 'rubocop-rails'
gem 'sass-rails'
gem 'sdoc', require: false
gem 'webpacker'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'govuk-lint'
  gem 'haml-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
  gem 'show_me_the_cookies'
  gem 'simplecov', require: false
  gem 'webdrivers'
  gem 'webmock'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
