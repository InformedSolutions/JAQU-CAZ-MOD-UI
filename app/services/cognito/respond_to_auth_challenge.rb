# frozen_string_literal: true

module Cognito
  class RespondToAuthChallenge < CognitoBaseService
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

      Rails.logger.error "[#{self.class}] Invalid form params"
      raise NewPasswordException, form.error_object
    end

    def update_user(access_token)
      @user = Cognito::GetUser.call(
        access_token: access_token,
        user: user,
        username: user.username
      )
    end

    def respond_to_auth
      call_cognito
    rescue AWS_ERROR::InvalidPasswordException => e
      log_error e
      raise NewPasswordException, self.class.password_complexity_error
    rescue AWS_ERROR::ServiceError => e
      log_error e
      raise CallException, I18n.t('expired_session')
    end

    def call_cognito
      log_action "Respond to auth call by a user: #{user.username}"
      result = COGNITO_CLIENT.respond_to_auth_challenge(
        challenge_name: 'NEW_PASSWORD_REQUIRED',
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        session: user.aws_session,
        challenge_responses: { 'NEW_PASSWORD' => password, 'USERNAME' => user.username }
      )
      log_action 'The call was successful'
      result
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
