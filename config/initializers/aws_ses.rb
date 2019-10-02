# frozen_string_literal: true

# :nocov:
# SES_ACCESS_KEY_ID may override AWS_ACCESS_KEY_ID
access_id = ENV.fetch('SES_ACCESS_KEY_ID') do
  ENV.fetch('AWS_ACCESS_KEY_ID', 'example_key')
end

# SES_SECRET_ACCESS_KEY may override AWS_SECRET_ACCESS_KEY
secret_key = ENV.fetch('SES_SECRET_ACCESS_KEY') do
  ENV.fetch('AWS_SECRET_ACCESS_KEY', 'example_key')
end
# :nocov:

creds = Aws::Credentials.new(access_id, secret_key)

# default to Ireland, as SES is not supported in London
region = ENV.fetch('SES_REGION', 'eu-west-1')

Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, credentials: creds, region: region)
