# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the password change
  module ForgotPassword
    ##
    # Class responsible for checking limit the number of requests a user could make for a password reset request.
    # If reset counter is over 5 and last request was made less than 1h ago, user
    # redirects to the next page but without sending any email at all
    class RateLimitVerification < CognitoBaseService
      ##
      # Initializer method for the service
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      ##
      # Invokes call to AWS Cognito to get user data and checks limit the number of requests
      def call
        return if allow_to_reset_password?

        log_error 'User reached the password reset rate limit'
        raise Cognito::CallException.new('', forgot_password_error_path)
      end

      private

      # Variable used internally by the service
      attr_reader :username

      # Returns nil if reset counter is not over 5 and last request was made more than 1h ago
      def allow_to_reset_password?
        reset_counter = extract_attr('custom:pw-reset-counter').to_i
        if reset_counter > 5
          last_request_1_hour_ago? ? (reset_counter = 1) : (return nil)
        else
          reset_counter += 1
        end
        admin_update_user(reset_counter)
      end

      # Checks if last request was made more than 1h ago
      def last_request_1_hour_ago?
        reset_requested_integer = extract_attr('custom:pw-reset-requested').to_i
        last_request_date = DateTime.strptime(reset_requested_integer.to_s, '%s')
        last_request_date < (DateTime.current - 1.hour)
      end

      # Returns an integer, eg. 2
      def extract_attr(name)
        user_data.user_attributes.find { |attr| attr.name == name }&.value
      end

      # Perform call to Cognito and get user data
      # Returns instance of OpenStruct which is contains:
      # * +custom:pw-reset-counter+
      # * +custom:pw-reset-requested+
      def user_data
        unless defined? @user_data
          log_action 'Query rate limiting fields from user account'
          @user_data = Cognito::ForgotPassword::GetUser.call(username: username)
          log_successful_call
        end

        @user_data
      end

      # Perform call to Cognito and get user data
      def admin_update_user(reset_counter)
        Cognito::ForgotPassword::UpdateUser.call(
          reset_counter: reset_counter,
          username: username
        )
      end
    end
  end
end
