# frozen_string_literal: true

module Cognito
  class ConfirmForgotPassword < BaseService
    attr_reader :username, :password, :code, :password_confirmation

    ERROR_CLASS = Aws::CognitoIdentityProvider::Errors

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

    def validate_params
      form = ConfirmResetPasswordForm.new(
        password: password,
        confirmation: password_confirmation,
        code: code
      )
      return if form.valid?

      Rails.logger.error "[#{self.class.name}] Invalid params - #{form.message}"
      raise CallException, form.message
    end

    def preform_cognito_call
      cognito_call
    rescue ERROR_CLASS::CodeMismatchException, ERROR_CLASS::ExpiredCodeException => e
      log_error e
      raise CallException, I18n.t('password.errors.code_mismatch')
    rescue ERROR_CLASS::InvalidPasswordException, ERROR_CLASS::InvalidParameterException => e
      log_error e
      raise CallException, I18n.t('password.errors.complexity')
    rescue ERROR_CLASS::ServiceError => e
      log_error e
      raise CallException, 'Something went wrong'
    end

    def cognito_call
      log_action "Confirming forgot password by a user: #{username}"
      COGNITO_CLIENT.confirm_forgot_password(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        username: username,
        password: password,
        confirmation_code: code
      )
      log_action 'The call was successful'
    end
  end
end
