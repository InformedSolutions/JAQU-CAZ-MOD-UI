# frozen_string_literal: true

module Cognito
  ##
  # Base class for all the Cognito services. Inherits from BaseService.
  #
  class CognitoBaseService < BaseService
    # Symbolizes base class for all Aws::CognitoIdentityProvider errors.
    AWS_ERROR = Aws::CognitoIdentityProvider::Errors

    # Logs success message on +info+ level
    def log_successful_call
      log_action 'The call was successful'
    end

    # Logs invalid form message on +error+ level
    #
    # ==== Attributes
    # * +msg+ - Invalid form details message. May include information which field is invalid
    #
    def log_invalid_params(msg)
      Rails.logger.error "[#{self.class.name}] Invalid form params - #{msg}"
    end

    # Returns a string, eg. '/passwords/confirm_reset'
    def forgot_password_error_path
      Rails.application.routes.url_helpers.confirm_reset_passwords_path
    end

    # The user pool ID for the user pool where we want to update user attributes
    def user_pool_id
      ENV['AWS_COGNITO_USER_POOL_ID']
    end
  end
end
