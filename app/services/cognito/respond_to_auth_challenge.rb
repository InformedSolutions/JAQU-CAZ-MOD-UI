# frozen_string_literal: true

module Cognito
  ##
  # Class responsible for validating user data and perform set a new password when user sign in for
  # the first time.
  #
  class RespondToAuthChallenge < CognitoBaseService
    # Variables used internally by the service
    attr_reader :user, :password, :confirmation

    ##
    # Initializer method for the service.
    #
    # ==== Attributes
    # * +user+ - string, user email address
    # * +password+ - string, password submitted by the user
    # * +confirmation+ - string, password confirmation submitted by the user
    def initialize(user:, password:, confirmation:)
      @user = user
      @password = password
      @confirmation = confirmation
    end

    ##
    # Invokes the user params validation and perform call to AWS Cognito.
    #
    # Returns an instance of {User class}[rdoc-ref:User]
    def call
      validate_params
      response = respond_to_auth
      update_user(response.authentication_result.access_token)
      user
    end

    private

    # Validates user data.
    # Raise exception if validation failed.
    def validate_params
      form = NewPasswordForm.new(
        password: password, confirmation: confirmation, old_password_hash: user.hashed_password
      )
      return if form.valid?

      log_invalid_params(form.error_object[:base_message])
      raise NewPasswordException, form.error_object
    end

    # Gets updated user data from Cognito.
    #
    # Returns an instance of {User class}[rdoc-ref:User]
    def update_user(access_token)
      @user = Cognito::GetUser.call(
        access_token: access_token,
        user: user,
        username: user.username
      )
    end

    # Sets a new user password on Cognito.
    #
    # Raise exception if validation failed.
    def respond_to_auth
      call_cognito
    rescue AWS_ERROR::InvalidPasswordException => e
      log_error e
      raise NewPasswordException, self.class.password_complexity_error
    rescue AWS_ERROR::ServiceError => e
      log_error e
      raise CallException, I18n.t('expired_session')
    end

    # Sets a new user password on Cognito.
    def call_cognito
      log_action "Respond to auth call by a user: #{user.username}"
      result = COGNITO_CLIENT.respond_to_auth_challenge(
        challenge_name: 'NEW_PASSWORD_REQUIRED',
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        session: user.aws_session,
        challenge_responses: { 'NEW_PASSWORD' => password, 'USERNAME' => user.username }
      )
      log_successful_call
      result
    end

    class << self
      # Returns hash, error message.
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
