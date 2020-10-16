# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Singleton Class used to request Cognito client.
  class Client
    include Singleton

    attr_reader :client

    ##
    # Initializer method for the service.
    #
    def initialize
      @client = load_client
    end

    ##
    # Method called when class does not implement the method
    # Then we try to call Cognito Client if respond to that method
    def method_missing(method, *args, &block)
      return client.send(method, *args, &block) if respond_to_missing?(method)

      super
    rescue Aws::CognitoIdentityProvider::Errors::ResourceNotFoundException,
           Aws::CognitoIdentityProvider::Errors::UnrecognizedClientException => e
      Rails.logger.info "Rescue From: #{e.class.name} - rotate credentials"
      # reload Cognito Client
      @client = load_client
      # retry
      client.send(method, *args, &block)
    end

    ##
    # Method which check if Cognito Client respond to the missing method.
    def respond_to_missing?(method, include_private = false) # rubocop:disable Style/OptionalBooleanParameter
      client.respond_to?(method) || super
    end

    private

    # Loads AWS Cognito Client
    def load_client
      return Aws::CognitoIdentityProvider::Client.new unless cognito_sdk_secret

      Aws::CognitoIdentityProvider::Client.new(credentials: secret_manager_credentials)
    end

    # Check if COGNITO_SDK_SECRET is set
    def cognito_sdk_secret
      ENV['COGNITO_SDK_SECRET']
    end

    # Loads Credentials from SecretManager
    def secret_manager_credentials
      sm_credentials = JSON.parse(
        secret_manager_client.get_secret_value(secret_id: cognito_sdk_secret).secret_string
      )
      Aws::Credentials.new(
        sm_credentials['awsAccessKeyId'],
        sm_credentials['awsSecretAccessKey']
      )
    end

    # Loads SecretManager Client.
    def secret_manager_client
      Aws::SecretsManager::Client.new(
        region: ENV['AWS_REGION'],
        credentials: Aws::ECSCredentials.new({ ip_address: '169.254.170.2' })
      )
    end
  end
end
