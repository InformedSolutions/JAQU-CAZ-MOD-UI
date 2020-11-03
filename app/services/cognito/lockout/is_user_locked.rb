# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
module Cognito
  ##
  # Module used to manage the account lockout
  module Lockout
    ##
    # Class responsible for checking whether provided user is locked.
    #
    class IsUserLocked < CognitoBaseService
      ##
      # Initializer method for the service.
      #
      # ==== Attributes
      # * +username+ - string, user email address
      def initialize(username:)
        @username = username
      end

      ##
      # Checks if user is locked. Removes lockout when it's possible.
      # Returns boolean.
      def call
        user_data.locked?
      end

      private

      attr_reader :username

      # Method calls service which returns user data.
      def user_data
        @user_data ||= Cognito::Lockout::UserData.new(username: username)
      end
    end
  end
end
