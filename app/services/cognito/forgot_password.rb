# frozen_string_literal: true

module Cognito
  class ForgotPassword < BaseService
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

      raise CallException.new(form.message, error_path)
    end

    def cognito_call
      Rails.logger.info "[Cognito] Forgot password call by a user: #{username}"
      COGNITO_CLIENT.forgot_password(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        username: username
      )
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      Rails.logger.error "[Cognito] #{e.class}: { username: #{username}, error: #{e}}"
    end
  end
end
