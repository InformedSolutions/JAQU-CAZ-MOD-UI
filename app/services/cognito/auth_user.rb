# frozen_string_literal: true

module Cognito
  class AuthUser < BaseService
    attr_reader :username, :password, :user

    def initialize(username:, password:)
      @username = username
      @password = password
      @user = User.new
    end

    def call
      update_user(auth_user)
      user
    end

    private

    def auth_user
      Rails.logger.info "[Cognito] Authenticating user: #{username}"
      COGNITO_CLIENT.initiate_auth(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        auth_flow: 'USER_PASSWORD_AUTH',
        auth_parameters:
          {
            'USERNAME' => username,
            'PASSWORD' => password
          }
      )
    end

    def update_user(auth_response)
      if auth_response.authentication_result
        update_unchallenged_user(auth_response.authentication_result.access_token)
      else
        update_challenged_user(auth_response)
      end
    end

    def update_challenged_user(auth_response)
      challenge_parameters = auth_response.challenge_parameters
      user.username = challenge_parameters['USER_ID_FOR_SRP']
      user.email = JSON.parse(challenge_parameters['userAttributes'])['email']
      user.aws_status = 'FORCE_NEW_PASSWORD'
      user.aws_session = auth_response.session
      user.hashed_password = Digest::MD5.hexdigest(password)
    end

    def update_unchallenged_user(access_token)
      @user = Cognito::GetUser.call(access_token: access_token)
    end
  end
end
