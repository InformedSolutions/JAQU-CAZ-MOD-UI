# frozen_string_literal: true

AMAZON_S3_CLIENT = Aws::S3::Resource.new(
  region: ENV.fetch('S3_AWS_REGION', 'S3_AWS_REGION'),
  access_key_id: ENV.fetch('S3_AWS_ACCESS_KEY_ID', 'S3_AWS_ACCESS_KEY_ID'),
  secret_access_key: ENV.fetch('S3_AWS_SECRET_ACCESS_KEY', 'S3_AWS_SECRET_ACCESS_KEY')
)
