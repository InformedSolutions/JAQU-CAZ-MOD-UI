# frozen_string_literal: true

class PasswordsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]
  before_action :validate_aws_status, only: %i[new create]
  before_action :validate_aws_session, only: %i[new create]
  before_action :validate_password_reset_token,
                only: %i[send_confirmation_code confirm_reset change]

  def new
    # renders view for initial password change
  end

  def create
    respond_to_auth
  rescue Cognito::CallException => e
    sign_out current_user
    redirect_to new_user_session_path, alert: e.message
  rescue NewPasswordException => e
    @error = e.error_object
    render :new
  end

  def success
    # change actions success page
  end

  def reset
    session[:password_reset_token] = SecureRandom.uuid
  end

  def send_confirmation_code
    Cognito::ForgotPassword.call(username: username)
    session[:password_reset_username] = username
    redirect_to confirm_reset_passwords_path
  rescue Cognito::CallException => e
    redirect_to e.path, alert: e.message
  end

  def confirm_reset
    unless session[:password_reset_username]
      return redirect_to new_user_session_path, alert: 'Email is missing'
    end

    @username = session[:password_reset_username]
  end

  def change
    Cognito::ConfirmForgotPassword.call(
      username: username,
      password: password,
      code: code,
      password_confirmation: password_confirmation
    )
    %w[token username].each { |attr| session["password_reset_#{attr}".to_sym] = nil }
    redirect_to success_passwords_path
  rescue Cognito::CallException => e
    redirect_to confirm_reset_passwords_path, alert: e.message
  end

  private

  def respond_to_auth
    Cognito::RespondToAuthChallenge.call(
      user: current_user, password: password, confirmation: password_confirmation
    )
    update_session_data
    redirect_to success_passwords_path
  end

  def update_session_data
    session['warden.user.user.key'] = [current_user.serializable_hash.transform_keys(&:to_s), nil]
  end

  def validate_aws_status
    return if current_user.aws_status == 'FORCE_NEW_PASSWORD'

    redirect_to root_path
  end

  def validate_aws_session
    return if current_user.aws_session

    sign_out current_user
    redirect_to new_user_session_path, alert: I18n.t('expired_session')
  end

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

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :username, :confirmation_code)
  end

  def password
    password_params[:password]
  end

  def password_confirmation
    password_params[:password_confirmation]
  end

  def username
    password_params[:username]
  end

  def code
    password_params[:confirmation_code]
  end
end
