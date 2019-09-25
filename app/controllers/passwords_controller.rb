# frozen_string_literal: true

##
# Controller class for the password change.
#
class PasswordsController < ApplicationController
  # checks if a user is logged in
  before_action :authenticate_user!, only: %i[new create]
  # checks if a user has a 'FORCE_NEW_PASSWORD' status
  before_action :validate_aws_status, only: %i[new create]
  # checks if a user aws session not expired
  before_action :validate_aws_session, only: %i[new create]
  # prevent browser page caching if a password_reset_token is present
  before_action :validate_password_reset_token,
                only: %i[send_confirmation_code confirm_reset change]

  ##
  # Renders the password change page.
  #
  # ==== Path
  #
  #    GET /passwords/new
  #
  def new
    # renders view for initial password change
  end

  ##
  # Sets a new password when user sign in for the first time.
  #
  # ==== Path
  #
  #    :POST /passwords/create
  #
  def create
    respond_to_auth
  rescue Cognito::CallException => e
    sign_out current_user
    redirect_to new_user_session_path, alert: e.message
  rescue NewPasswordException => e
    @error = e.error_object
    render :new
  end

  ##
  # Renders the password change success page.
  #
  # ==== Path
  #
  #    :POST /passwords/success
  #
  def success
    # change actions success page
  end

  ##
  # Sets password_reset_token.
  #
  # ==== Path
  #
  #    :GET /passwords/reset
  #
  def reset
    session[:password_reset_token] = SecureRandom.uuid
  end

  ##
  # Sent +confirmation_code+ to user email address.
  #
  # ==== Path
  #
  #    :POST /passwords/send_confirmation_code
  #
  # ==== Params
  # * +username+ - user email address, eg 'email@example.com'
  #
  # ==== Exceptions
  # Any exception raised during {API call}[rdoc-ref:Cognito::ForgotPassword.call]
  # redirects to the {password reset page}[rdoc-ref:PasswordsController.reset]
  #
  def send_confirmation_code
    Cognito::ForgotPassword.call(username: username)
    session[:password_reset_username] = username
    redirect_to confirm_reset_passwords_path
  rescue Cognito::CallException => e
    redirect_to e.path, alert: e.message
  end

  ##
  # Renders the confirm_reset page.
  #
  # ==== Path
  #
  #    :GET /passwords/confirm_reset
  #
  def confirm_reset
    unless session[:password_reset_username]
      return redirect_to new_user_session_path, alert: 'Email is missing'
    end

    @username = session[:password_reset_username]
  end

  ##
  # Sets provided new password in Cognito.
  #
  # ==== Path
  #
  #    :POST /passwords/change
  #
  # ==== Params
  # * +username+ - string, user email address
  # * +password+ - string, password submitted by the user
  # * +password_confirmation+ - string, password confirmation submitted by the user
  # * +code+ - 6 digit string of numbers, code sent to user
  #
  # ==== Exceptions
  # Any exception raised during {API call}[rdoc-ref:Cognito::ConfirmForgotPassword.call]
  # redirects to the {password reset page}[rdoc-ref:PasswordsController.confirm_reset]
  #
  def change
    Cognito::ConfirmForgotPassword.call(
      username: username,
      password: password,
      password_confirmation: password_confirmation,
      code: code
    )
    %w[token username].each { |attr| session["password_reset_#{attr}".to_sym] = nil }
    redirect_to success_passwords_path
  rescue Cognito::CallException => e
    redirect_to confirm_reset_passwords_path, alert: e.message
  end

  private

  # Sets a new password when user sign in for the first time.
  def respond_to_auth
    Cognito::RespondToAuthChallenge.call(
      user: current_user, password: password, confirmation: password_confirmation
    )
    update_session_data
    redirect_to success_passwords_path
  end

  # Updates user session data with a new response from Cognito.
  def update_session_data
    session['warden.user.user.key'] = [current_user.serializable_hash.transform_keys(&:to_s), nil]
  end

  # Checks if user +aws_status+ equality to 'FORCE_NEW_PASSWORD'.
  def validate_aws_status
    return if current_user.aws_status == 'FORCE_NEW_PASSWORD'

    redirect_to root_path
  end

  # Checks if user +aws_session+ is present. If not sign out user and redirect to sign in page.
  def validate_aws_session
    return if current_user.aws_session

    sign_out current_user
    redirect_to new_user_session_path, alert: I18n.t('expired_session')
  end

  # prevent browser page caching if a password_reset_token is present.
  def validate_password_reset_token
    if session[:password_reset_token]
      # https://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails
      response.headers['Cache-Control'] = 'no-cache, no-store'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    else
      redirect_to success_passwords_path
    end
  end

  # Returns the list of permitted params
  def password_params
    params.require(:user).permit(:password, :password_confirmation, :username, :confirmation_code)
  end

  # Returns a string
  def password
    password_params[:password]
  end

  # Returns a string
  def password_confirmation
    password_params[:password_confirmation]
  end

  # Returns a string
  def username
    password_params[:username]
  end

  # Returns a string
  def code
    password_params[:confirmation_code]
  end
end
