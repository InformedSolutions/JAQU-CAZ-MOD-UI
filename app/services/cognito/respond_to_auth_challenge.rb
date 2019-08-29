# frozen_string_literal: true

module Cognito
  class RespondToAuthChallenge < BaseService
    attr_reader :user, :password, :confirmation

    def initialize(user:, password:, confirmation:)
      @user = user
      @password = password
      @confirmation = confirmation
    end

    def call
      validate_params
      response = respond_to_auth
      update_user(response.authentication_result.access_token)
      user
    end

    private

    def validate_params
      form = NewPasswordForm.new(
        password: password, confirmation: confirmation, old_password_hash: user.hashed_password
      )
      return if form.valid?

      raise NewPasswordException, form.error_object
    end

    def update_user(access_token)
      @user = Cognito::GetUser.call(access_token: access_token, user: user)
    end

    def respond_to_auth
      Rails.logger.info "[Cognito] Respond to auth call by a user: #{user.username}"
      call_cognito
    rescue Aws::CognitoIdentityProvider::Errors::InvalidPasswordException
      raise NewPasswordException, self.class.password_complexity_error
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      Rails.logger.error e
      raise CallException, I18n.t('expired_session')
    end

    def call_cognito
      COGNITO_CLIENT.respond_to_auth_challenge(
        challenge_name: 'NEW_PASSWORD_REQUIRED',
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        session: user.aws_session,
        challenge_responses: {
          'NEW_PASSWORD' => password,
          'USERNAME' => user.username
        }
      )
    end

    class << self
      def password_complexity_error
        {
          base_message: I18n.t('password.errors.complexity'),
          link: true,
          password: I18n.t('password.errors.complexity')
        }
      end
    end
  end
end
