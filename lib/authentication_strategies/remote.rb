# frozen_string_literal: true

##
# Module used to wrap communication with Amazon Cognito
#
# Configuration of the client is done in config/initializers/cognito_client.rb and by ENV variables
#
module AuthenticationStrategies
  ##
  # Class responsible for validating user email and authenticating user.
  #
  class Remote < Devise::Strategies::Authenticatable
    # For an example check:
    # https://github.com/plataformatec/devise/blob/master/lib/devise/strategies/database_authenticatable.rb
    # Method called by warden to authenticate a resource.
    def authenticate!
      error = EmailValidator.call(email: username)
      return fail!(error) if error

      # authentication_hash doesn't include the password
      auth_params = authentication_hash
      auth_params[:password] = password

      # mapping.to is a wrapper over the resource model
      resource = mapping.to.new
      return fail! unless resource

      authenticate_user(resource, auth_params)
    end

    private

    # Returns a string, eg. 'user@example.com'
    def username
      authentication_hash[:username]
    end

    def authenticate_user(resource, auth_params)
      # remote_authentication method is defined in Devise::Models::RemoteAuthenticatable
      #
      # validate is a method defined in Devise::Strategies::Authenticatable. It takes
      # a block which must return a boolean value.
      #
      # If the block returns true the resource will be logged in
      # If the block returns false the authentication will fail!
      #
      # resource = resource.authentication(auth_params)
      if validate(resource) { resource = resource.authentication(auth_params) }
        validate_authorized_list_type(resource)
      else
        fail!(:invalid)
      end
    end

    # Validates the authorized list type. It must be the `green` or `white`.
    #
    # @param user [User]
    #
    # @return [Symbol] - :success or :failure
    def validate_authorized_list_type(user)
      if %w[green white].include?(user.authorized_list_type)
        success!(user)
      else
        Rails.logger.error "[#{self.class.name}] Invalid authorized list type"
        fail!('Invalid authorized list type')
      end
    end
  end
end
