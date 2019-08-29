# frozen_string_literal: true

class User
  # required by Devise
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend Devise::Models

  define_model_callbacks :validation
  devise :remote_authenticatable, :timeoutable

  attr_accessor :email, :username, :aws_status, :aws_session, :sub,
                :confirmation_code, :hashed_password

  # Latest devise(v4.6.2) tries to initialize this class with values
  # ignore it for now
  def initialize(options = {}); end

  # needed for rendering user forms
  def to_key
    nil
  end

  # needed for displaying user in console
  def serializable_hash(_options = nil)
    {
      email: email,
      username: username,
      aws_status: aws_status,
      aws_session: aws_session,
      sub: sub,
      hashed_password: hashed_password
    }
  end
end
