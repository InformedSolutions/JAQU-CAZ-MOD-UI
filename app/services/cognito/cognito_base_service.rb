# frozen_string_literal: true

module Cognito
  ##
  # Base class for all the Cognito services. Inherits from BaseService.
  #
  class CognitoBaseService < BaseService
    # Symbolizes base class for all Aws::CognitoIdentityProvider errors.
    AWS_ERROR = Aws::CognitoIdentityProvider::Errors
    # Names of the custom Cognito attributes
    FAILED_LOGINS_ATTR = 'custom:failed-logins'
    LOCKOUT_TIME_ATTR = 'custom:lockout-time'
    # Env variables associated with the lockout mechanism
    LOCKOUT_LOGIN_ATTEMPTS = ENV.fetch('LOCKOUT_LOGIN_ATTEMPTS', 5).to_i
    LOCKOUT_TIMEOUT = ENV.fetch('LOCKOUT_TIMEOUT', 30).to_i

    # Logs success message on +info+ level
    def log_successful_call
      log_action 'The call was successful'
    end

    # Returns a string, eg. '/passwords/confirm_reset'
    def forgot_password_error_path
      Rails.application.routes.url_helpers.confirm_reset_passwords_path
    end

    # The user pool ID for the user pool where we want to update user attributes
    def user_pool_id
      ENV['AWS_COGNITO_USER_POOL_ID'].split('/').last
    end

    private

    def client
      Cognito::Client.instance
    end
  end
end
