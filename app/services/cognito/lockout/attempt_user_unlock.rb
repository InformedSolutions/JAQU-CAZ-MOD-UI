# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the account lockout
  module Lockout
    ##
    # Class responsible for unlocking user when user can be unlocked
    class AttemptUserUnlock < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      ##
      # Unlocks user when it's possible
      def call
        unlock_user if user_data.unlockable?
      end

      private

      attr_reader :username

      # Method unlocks the user but starts counting invalid login attempts.
      def unlock_user
        update_user(failed_logins: 0)
      end

      # Method calls service which returns user data.
      def user_data
        @user_data ||= Cognito::Lockout::UserData.new(username: username)
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
