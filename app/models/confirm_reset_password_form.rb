# frozen_string_literal: true

##
# This class is used to validate user data filled in +app/views/passwords/confirm_reset.html.haml+.
class ConfirmResetPasswordForm < BaseForm
  # Submitted password
  attr_reader :password
  # Submitted password confirmation
  attr_reader :confirmation
  # Submitted confirmation code
  attr_reader :code

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +password+ - string, eg. 'password'
  # * +confirmation+ - string, eg. 'password'
  # * +code+ - string, eg. '123456'
  def initialize(password:, confirmation:, code:)
    @password = password
    @confirmation = confirmation
    @code = code
    super(nil)
  end

  ##
  # Validate user data.
  #
  # Returns a boolean.
  def valid?
    filled_code? && filled_passwords? && correct_password_confirmation?
  end

  private

  # Checks if +code+  was entered.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def filled_code?
    return true if code.present?

    @message = I18n.t('password.errors.code_required')
    false
  end

  # Checks if +password+ and +confirmation+ was entered.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def filled_passwords?
    return true if password.present? && confirmation.present?

    @message = I18n.t('password.errors.password_required')
    false
  end

  # Checks if +password+ and +confirmation+ password are same.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def correct_password_confirmation?
    return true if password == confirmation

    @message = I18n.t('password.errors.password_equality')
    false
  end
end
