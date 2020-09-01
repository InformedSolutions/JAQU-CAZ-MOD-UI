# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the account lockout
  module Lockout
    ##
    # Class responsible for requesting a Cognito service to update account lockout attributes
    #
    class UpdateUser < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      # * +failed_logins+ - integer, failed logins counter
      # * +lockout_time+ - integer, current datetime converted to integer
      def initialize(username:, failed_logins:, lockout_time: nil)
        @username = username
        @failed_logins = failed_logins
        @lockout_time = lockout_time
      end

      ##
      # Perform the call to AWS Cognito and returns true if errors were not raised
      def call
        admin_update_user
        true
      end

      private

      # Variables used internally by the service
      attr_reader :username, :failed_logins, :lockout_time

      # Perform the call to Cognito service to update user attributes
      def admin_update_user
        log_action 'Updating user attributes associated with account lockout'
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
            name: FAILED_LOGINS_ATTR,
            value: failed_logins.to_s
          },
          {
            name: LOCKOUT_TIME_ATTR,
            value: lockout_time.to_s
          }
        ]
      end
    end
  end
end
