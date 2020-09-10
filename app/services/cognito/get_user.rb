# frozen_string_literal: true

module Cognito
  ##
  # Class responsible for getting actual user data from Cognito.
  #
  class GetUser < CognitoBaseService
    # Variables used internally by the service
    attr_reader :access_token, :user, :username

    ##
    # Initializer method for the service.
    #
    # ==== Attributes
    # * +access_token+ - UUID , eg. '8d414417-2bbe-4e70-a145-e108f45d33d3'
    # * +user+ - instance of {User class}[rdoc-ref:User]
    # * +username+ - string, user email address
    def initialize(access_token:, username:, user: User.new)
      @access_token = access_token
      @user = user
      @username = username&.downcase
    end

    ##
    # Sets the details of current user using Cognito response.
    def call
      update_user
      user
    end

    private

    # Sets the details of current user using Cognito response.
    def update_user
      user.username = user_data.username
      user.email = extract_attr('email')
      user.sub = extract_attr('sub')
      user.authorized_list_type = extract_attr('custom:authorized-list-type')&.downcase
      user.aws_status = 'OK'
    end

    # Returns a string, eg. `test@example.com`
    def extract_attr(name)
      user_data.user_attributes.find { |attr| attr.name == name }&.value
    end

    # Returns instance of OpenStruct which is contains:
    # * +username+ - string, username, eg. 'test'
    # * +email+ - string, user email address, eg. 'test@example.com'
    # * +sub+ - UUID, eg '685f6373-75bc-4cb9-9a01-dbe1f9c383cf'
    def user_data
      unless defined? @user_data
        log_action 'Getting user'
        @user_data = client.get_user(access_token: access_token)
        log_successful_call
      end

      @user_data
    end
  end
end
