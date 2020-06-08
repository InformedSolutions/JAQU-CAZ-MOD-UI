# frozen_string_literal: true

credentials = if ENV['S3_AWS_ACCESS_KEY_ID']
                Aws::Credentials.new(
                  ENV.fetch('S3_AWS_ACCESS_KEY_ID', 'S3_AWS_ACCESS_KEY_ID'),
                  ENV.fetch('S3_AWS_SECRET_ACCESS_KEY', 'S3_AWS_SECRET_ACCESS_KEY')
                )
              else
                Aws::ECSCredentials.new({ ip_address: '169.254.170.2' })
              end

AMAZON_S3_CLIENT = Aws::S3::Resource.new(
  region: ENV.fetch('S3_AWS_REGION', 'S3_AWS_REGION'),
  credentials: credentials
)
