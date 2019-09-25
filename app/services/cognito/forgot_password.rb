# frozen_string_literal: true

module Cognito
  ##
  # Class responsible for requesting a Cognito service to perform email send with a new
  # temporary password.
  #
  class ForgotPassword < CognitoBaseService
    # Variable used internally by the service
    attr_reader :username

    ##
    # Initializer method for the service.
    #
    # ==== Attributes
    # * +username+ - string, user email address
    def initialize(username:)
      @username = username
    end

    ##
    # Invokes the user params validation and perform call to AWS Cognito.
    def call
      validate_params
      cognito_call
      true
    end

    private

    # Returns a string, eg. '/passwords/reset'
    def error_path
      Rails.application.routes.url_helpers.reset_passwords_path
    end

    # Validates user data.
    # Raise exception if validation failed.
    def validate_params
      form = ResetPasswordForm.new(username)
      return if form.valid?

      log_invalid_params(form.message)
      raise CallException.new(form.message, error_path)
    end

    # Requests a Cognito service to perform email send with a new temporary password.
    def cognito_call
      log_action "Forgot password call by a user: #{username}"
      COGNITO_CLIENT.forgot_password(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        username: username
      )
      log_successful_call
    rescue AWS_ERROR::ServiceError => e
      log_error e
    end
  end
end
