# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the account lockout
  module Lockout
    ##
    # Class responsible for reacting to situation when user provided a valid username but invalid password.
    #
    class VerifyInvalidLogins < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      ##
      # Updates user cognito attributes based on their current value.
      def call
        increment_failed_logins unless invalid_logins_exceeded?
        lock_user if invalid_logins_exceeded? && !user_data.locked?
        unlock_user if invalid_logins_exceeded? && user_data.unlockable?
      end

      private

      attr_reader :username

      # Method checks if user exceeded maximum invalid login attempts.
      # Returns boolean.
      def invalid_logins_exceeded?
        user_data(reload: true).invalid_logins >= LOCKOUT_LOGIN_ATTEMPTS
      end

      # Method calls update service with the incremented invalid login count.
      def increment_failed_logins
        update_user(failed_logins: user_data.invalid_logins + 1)
      end

      # Method class update service with data locking out the user.
      def lock_user
        update_user(
          failed_logins: user_data.invalid_logins,
          lockout_time: Time.zone.now.iso8601
        )
      end

      # Method unlocks the user but starts counting invalid login attempts.
      def unlock_user
        update_user(failed_logins: 1)
      end

      # Method returns either already stored user data or fetches them from Cognito.
      def user_data(reload: false)
        reload ? (@user_data = user_data_call) : (@user_data ||= user_data_call)
      end

      # Method calls service which returns user data.
      def user_data_call
        Cognito::Lockout::UserData.new(username: username)
      end

      # Method calls service responsible for user updates.
      def update_user(failed_logins:, lockout_time: nil)
        Cognito::Lockout::UpdateUser.call(
          username: username,
          failed_logins: failed_logins,
          lockout_time: lockout_time
        )
      end
    end
  end
end
