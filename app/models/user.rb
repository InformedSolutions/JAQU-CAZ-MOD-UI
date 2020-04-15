# frozen_string_literal: true

##
# This class is used to authorize a user account and to sign uploaded CSV documents.
class User
  # required by Devise
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend Devise::Models

  # Allows to use validation callbacks.
  define_model_callbacks :validation
  # Allow remote authentication with devise.
  devise :remote_authenticatable
  # Takes care of verifying whether a user session has already expired or not.
  devise :timeoutable

  # Attribute that is being used to authorize a user and use it in csv uploading.
  attr_accessor :email, :username, :aws_status, :aws_session, :sub,
                :confirmation_code, :hashed_password, :authorized_list_type, :login_ip

  # Overrides default initializer for compliance with Devise Gem.
  def initialize(options = {})
    options.each do |key, value|
      public_send("#{key}=", value) if respond_to?(key)
    end
  end

  # Used in devise and should return nil when the object is not persisted.
  def to_key
    nil
  end

  # Returns a serialized hash of your object.
  #
  # ==== Example
  #   user = User.new
  #   user.email = 'example@email.com'
  #   user #<User email: example@email.com, username: nil, ...>
  #   user.serializable_hash #{:email=>"example@email.com", :username=>nil, ...}
  def serializable_hash(_options = nil)
    {
      email: email,
      username: username,
      aws_status: aws_status,
      aws_session: aws_session,
      sub: sub,
      hashed_password: hashed_password,
      authorized_list_type: authorized_list_type,
      login_ip: login_ip
    }
  end
end
