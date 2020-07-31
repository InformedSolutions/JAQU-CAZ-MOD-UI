# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the password change
  module ForgotPassword
    ##
    # Class responsible for requesting a Cognito service to update rate limiting fields
    #
    class UpdateUser < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +reset_counter+ - integer, password reset counter
      # * +username+ - string, user email address
      # * +current_date_time+ - integer, current datetime converted to integer
      def initialize(reset_counter: 0, username:)
        @reset_counter = reset_counter
        @username = username
        @current_date_time = DateTime.current.to_i
      end

      ##
      # Perform the call to AWS Cognito and returns true if errors were not raised
      def call
        admin_update_user
        true
      end

      private

      # Variables used internally by the service
      attr_reader :username, :reset_counter, :current_date_time

      # Perform the call to Cognito service to update user attributes
      def admin_update_user
        log_action "Updating the password reset rate limit fields to: #{reset_counter}"
        client.admin_update_user_attributes(
          { user_pool_id: user_pool_id, username: username, user_attributes: user_attributes }
        )
        log_successful_call
      rescue AWS_ERROR::ServiceError => e
        log_error e
        raise CallException, 'Something went wrong'
      end

      # An array of name-value pairs representing user attributes we want to update
      def user_attributes
        [
          {
            name: 'custom:pw-reset-counter',
            value: reset_counter.to_s
          },
          {
            name: 'custom:pw-reset-requested',
            value: current_date_time.to_s
          }
        ]
      end
    end
  end
end
