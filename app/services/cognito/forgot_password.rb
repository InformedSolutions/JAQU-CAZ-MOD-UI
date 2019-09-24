# frozen_string_literal: true

module Cognito
  class ForgotPassword < CognitoBaseService
    attr_reader :username

    def initialize(username:)
      @username = username
    end

    def call
      validate_params
      cognito_call
      true
    end

    private

    def error_path
      Rails.application.routes.url_helpers.reset_passwords_path
    end

    def validate_params
      form = ResetPasswordForm.new(username)
      return if form.valid?

      log_invalid_params(form.message)
      raise CallException.new(form.message, error_path)
    end

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
