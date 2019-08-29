# frozen_string_literal: true

module AuthenticationStrategies
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
        success!(resource)
      else
        fail!(:invalid)
      end
    end
  end
end
