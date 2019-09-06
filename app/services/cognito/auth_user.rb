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
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      log_error e
      false
    end

    private

    def auth_user
      log_action "Authenticating user: #{username}"
      result = COGNITO_CLIENT.initiate_auth(
        client_id: ENV['AWS_COGNITO_CLIENT_ID'],
        auth_flow: 'USER_PASSWORD_AUTH',
        auth_parameters:
          { 'USERNAME' => username, 'PASSWORD' => password }
      )
      log_action 'The call was successful'
      result
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

      user.tap do |u|
        u.username = challenge_parameters['USER_ID_FOR_SRP']
        u.email = parsed_attr(challenge_parameters, 'email')
        u.aws_status = 'FORCE_NEW_PASSWORD'
        u.aws_session = auth_response.session
        u.hashed_password = Digest::MD5.hexdigest(password)
        u.authorized_list_type = parsed_attr(challenge_parameters, authorized_list_type).downcase
      end
    end

    def authorized_list_type
      'custom:authorized-list-type'
    end

    def update_unchallenged_user(access_token)
      @user = Cognito::GetUser.call(access_token: access_token)
    end

    def parsed_attr(challenge_parameters, attr)
      JSON.parse(challenge_parameters['userAttributes'])[attr]
    end
  end
end
