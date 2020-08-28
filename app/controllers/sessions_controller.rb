# frozen_string_literal: true

##
# Controller class for overwriting Devise methods.
#
class SessionsController < Devise::SessionsController
  ##
  # Called on user login.
  #
  # ==== Path
  #
  #    :POST /users/sign_in
  #
  # ==== Params
  # * +username+ - string, user email address
  # * +password+ - string, password submitted by the user
  #
  def create
    if credentials_valid?
      super
    else
      redirect_to new_user_session_path
    end
  end

  private

  ##
  # Validate user data.
  # 1. Check if both inputs are filled.
  # 2. Check if email is in correct format.
  #
  # Returns a boolean.
  def credentials_valid?
    both_fields_filled? && email_format_valid?
  end

  ##
  # Checks if both email and password are filled
  #
  # Returns a boolean.
  def both_fields_filled?
    return true unless user_params['username'].blank? && user_params['password'].blank?

    flash[:errors] = {
      email: I18n.t('email.errors.required'),
      password: I18n.t('password.errors.required')
    }

    false
  end

  ##
  # Checks if email is in correct format
  #
  # Returns a boolean.
  def email_format_valid?
    error_message = EmailValidator.call(email: user_params['username'])
    return true if error_message.nil?

    flash[:errors] = {
      email: error_message,
      password: I18n.t('password.errors.required')
    }

    false
  end

  # Returns the list of permitted params
  def user_params
    params.require(:user).permit(:username, :password)
  end
end
