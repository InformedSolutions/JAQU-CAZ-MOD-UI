# frozen_string_literal: true

# %w[AWS_REGION AWS_COGNITO_CLIENT_ID S3_AWS_ACCESS_KEY_ID S3_AWS_SECRET_ACCESS_KEY S3_AWS_REGION
#    S3_AWS_BUCKET TAXI_PHV_REGISTER_API_URL].each do |var|
#   Rails.logger.debug("#{var} environment variable not set") if Dotenv::Railtie.load[var].blank?
# end
