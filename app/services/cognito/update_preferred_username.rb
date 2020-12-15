# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Class responsible for requesting a Cognito service to update `preferred_username` attribute
  #
  class UpdatePreferredUsername < CognitoBaseService
    ##
    # Initializer method for the service.
    #
    # ==== Attributes
    # * +username+ - string, user email address
    # * +preferred_username+ - UUID, eg '685f6373-75bc-4cb9-9a01-dbe1f9c383cf'
    # * +sub+ - UUID, eg '98faf123-d201-48cb-8fd5-4b30c1f80918'
    def initialize(username:, preferred_username:, sub:)
      @username = username
      @preferred_username = preferred_username
      @sub = sub
    end

    ##
    # Perform the call to AWS Cognito and returns true if errors were not raised
    def call
      return if preferred_username

      admin_update_user
    end

    private

    # Variables used internally by the service
    attr_reader :username, :preferred_username, :sub

    # Perform the call to Cognito service to update `preferred_username` attribute
    def admin_update_user
      log_action('Updating the preferred_username attribute')
      client.admin_update_user_attributes(
        { user_pool_id: user_pool_id, username: username, user_attributes: user_attributes }
      )
    rescue AWS_ERROR::ServiceError => e
      log_error e
      raise CallException, 'Something went wrong'
    end

    # An array of name-value pairs representing user attributes we want to update
    def user_attributes
      [
        {
          name: 'preferred_username',
          value: sub
        }
      ]
    end
  end
end
