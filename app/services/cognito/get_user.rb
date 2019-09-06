# frozen_string_literal: true

module Cognito
  class GetUser < BaseService
    attr_reader :access_token, :user

    def initialize(access_token:, user: User.new)
      @access_token = access_token
      @user = user
    end

    def call
      update_user
      user
    end

    private

    def update_user
      user.username = user_data.username
      user.email = extract_attr('email')
      user.sub = extract_attr('sub')
      user.authorized_list_type = extract_attr('custom:authorized-list-type').downcase
      user.aws_status = 'OK'
    end

    def extract_attr(name)
      user_data.user_attributes.find { |attr| attr.name == name }&.value
    end

    def user_data
      log_action "Getting user: #{user.username}"
      @user_data ||= COGNITO_CLIENT.get_user(access_token: access_token)
      log_action 'The call was successful'
      @user_data
    end
  end
end
