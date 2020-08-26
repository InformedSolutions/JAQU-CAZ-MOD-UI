# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the password change
  module Lockout
    ##
    # Class responsible for requesting a Cognito service to get rate limiting fields
    #
    class UserData < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      # Quantity of invalid login attempts.
      # Returns integer.
      def invalid_logins
        (extract_attr(FAILED_LOGINS_ATTR) || 0).to_i
      end

      # Time when user was locked out.
      # Returns ActiveSupport::TimeWithZone object when the value is set.
      # Returns nil otherwise.
      def lockout_time
        date_string = extract_attr(LOCKOUT_TIME_ATTR)
        date_string.blank? ? nil : Time.zone.parse(date_string)
      end

      # Returns information if user can be unlocked.
      # User can be unlocked only when he is already locked and his lockout time was longer
      def unlockable?
        lockout_time ? lockout_time_exceeded? : false
      end

      # Information if user is blocked.
      # Returns boolean.
      def locked?
        !lockout_time.nil?
      end

      private

      # Variable used internally by the service
      attr_reader :username

      # Perform the call to Cognito service to get user attributes
      def user_data
        @user_data ||= client.admin_get_user(
          {
            user_pool_id: user_pool_id,
            username: username
          }
        )
      end

      # Extracts provided parameter from the Cognito response
      def extract_attr(name)
        user_data.user_attributes.find { |attr| attr.name == name }&.value
      end

      # Verifies if set lockout time exceeded lockout timeout.
      # Returns boolean.
      def lockout_time_exceeded?
        lockout_time < LOCKOUT_TIMEOUT.minutes.ago
      end
    end
  end
end
