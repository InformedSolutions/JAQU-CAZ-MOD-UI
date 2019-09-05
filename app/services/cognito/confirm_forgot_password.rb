# frozen_string_literal: true

module Cognito
  class ConfirmForgotPassword < BaseService
    attr_reader :username, :password, :code, :password_confirmation

    def initialize(username:, password:, code:, password_confirmation:)
      @username = username
      @password = password
      @password_confirmation = password_confirmation
      @code = code
    end

    def call
      validate_params
      preform_cognito_call
      true
    end

    private

    def error_path
      Rails.application.routes.url_helpers.confirm_reset_passwords_path(username: username)
    end

    def validate_params
      form = ConfirmResetPasswordForm.new(
        password: password,
        confirmation: password_confirmation,
        code: code
      )
      return if form.valid?

      raise CallException.new(form.message, error_path)
    end

    def preform_cognito_call
      cognito_call
    rescue Aws::CognitoIdentityProvider::Errors::CodeMismatchException,
           Aws::CognitoIdentityProvider::Errors::ExpiredCodeException
      raise CallException.new(I18n.t('password.errors.code_mismatch'), error_path)
    rescue Aws::CognitoIdentityProvider::Errors::InvalidPasswordException,
           Aws::CognitoIdentityProvider::Errors::InvalidParameterException
      raise CallException.new(I18n.t('password.errors.complexity'), error_path)
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      Rails.logger.error e
      raise CallException.new('Something went wrong', error_path)
    end

    def cognito_call
      Rails.logger.info "[Cognito] Confirming forgot password by a user: #{username}"
      COGNITO_CLIENT.confirm_forgot_password(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        username: username,
        password: password,
        confirmation_code: code
      )
    end
  end
end
