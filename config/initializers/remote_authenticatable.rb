# frozen_string_literal: true

module Devise
  module Models
    module RemoteAuthenticatable
      extend ActiveSupport::Concern
      # Here you do the request to the external webservice
      #
      # If the authentication is successful you should return
      # a resource instance
      #
      # If the authentication fails you should return false
      def authentication(params)
        Cognito::AuthUser.call(
          username: params[:username],
          password: params[:password]
        )
      end

      module ClassMethods
        # Overridden methods from Devise::Models::Authenticatable
        #
        # This method is called from:
        # Warden::SessionSerializer in devise
        #
        # It takes as many params as elements had the array
        # returned in serialize_into_session
        #
        # Recreates a resource from session data
        def serialize_from_session(data, _salt)
          resource = new
          resource.serializable_hash.keys.each do |key|
            resource.public_send("#{key}=", data[key.to_s])
          end
          resource
        end

        #
        # Here you have to return and array with the data of your resource
        # that you want to serialize into the session
        #
        # You might want to include some authentication data
        #
        def serialize_into_session(record)
          [record.serializable_hash.transform_keys(&:to_s), nil]
        end
      end
    end
  end
end
