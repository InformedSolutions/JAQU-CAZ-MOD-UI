# frozen_string_literal: true

##
# This class is used to validate user data filled in +app/views/passwords/new.html.haml+.
class NewPasswordForm
  PASSWORD_EQUALITY_ERROR = I18n.t('password.errors.password_equality')

  # Submitted password
  attr_reader :password
  # Submitted password confirmation
  attr_reader :confirmation
  # Temporary password as a hex-encoded hash
  attr_reader :old_password_hash
  # Error messages as a hash
  attr_reader :error_object

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +password+ - string, eg. 'password'
  # * +confirmation+ - string, eg. 'password'
  # * +old_password_hash+ - string, eg. '0512f08120c4fef707bd5e2259c537d0'
  # * +error_object+ - empty hash, default error object
  def initialize(password:, confirmation:, old_password_hash:)
    @password = password
    @confirmation = confirmation
    @old_password_hash = old_password_hash
    @error_object = {}
  end

  ##
  # Validate user data.
  # 1. Check if at least one input is filled.
  # 2. Check if password is filled.
  # 3. Check if confirmation is filled.
  # 4. Check if new password is different than the old one.
  # 5. Check if password and confirmation are the same.
  #
  # Returns a boolean.
  def valid?
    any_input_filled? &&
      filled_password? &&
      filled_confirmation? &&
      password_changed? &&
      correct_password_confirmation?
  end

  # Checks if +password+ or +confirmation+ was entered.
  # If not (neither passwords are filled), add error message to +error_object+.
  #
  # Returns a boolean.
  def any_input_filled?
    return true if password.present? || confirmation.present?

    @error_object = {
      password: I18n.t('password.errors.password_required'),
      password_confirmation: I18n.t('password.errors.confirmation_required')
    }
    false
  end

  # Checks if +password+ was entered.
  # If not, add error message to +error_objects+.
  #
  # Returns a boolean
  def filled_password?
    return true if password.present?

    password_required = I18n.t('password.errors.password_required')

    @error_object = {
      password: password_required,
      password_confirmation: PASSWORD_EQUALITY_ERROR
    }

    false
  end

  # Checks if +confirmation+ was entered.
  # If not, add error message to +error_object+.
  #
  # Returns a boolean.
  def filled_confirmation?
    return true if confirmation.present?

    confirmation_required = I18n.t('password.errors.confirmation_required')

    @error_object = {
      password: PASSWORD_EQUALITY_ERROR,
      password_confirmation: confirmation_required
    }

    false
  end

  # Checks if new +password+ different than your temporary one.
  # If not, add error message to +error_object+.
  #
  # Returns a boolean.
  def password_changed?
    return true if old_password_hash && Digest::MD5.hexdigest(password) != old_password_hash

    @error_object = {
      base_message: I18n.t('password.errors.password_unchanged')
    }
    false
  end

  # Checks if +password+ and +confirmation+ password are same.
  # If not, add error messages to +error_object+.
  #
  # Returns a boolean.
  def correct_password_confirmation?
    return true if password == confirmation

    password_equality = PASSWORD_EQUALITY_ERROR
    @error_object = {
      password: password_equality,
      password_confirmation: password_equality
    }
    false
  end
end
