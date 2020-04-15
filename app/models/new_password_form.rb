# frozen_string_literal: true

##
# This class is used to validate user data filled in +app/views/passwords/new.html.haml+.
class NewPasswordForm
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
  #
  # Returns a boolean.
  def valid?
    passwords_filled? && password_changed? && correct_password_confirmation?
  end

  private

  # Checks if +password+ and +confirmation+ was entered.
  # If not, add error messages to +error_object+.
  #
  # Returns a boolean.
  def passwords_filled?
    return true if password.present? && confirmation.present?

    @error_object = {
      base_message: I18n.t('password.errors.passwords_required'),
      link: true,
      password: I18n.t('password.errors.password_required'),
      password_confirmation: I18n.t('password.errors.confirmation_required')
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
      base_message: I18n.t('password.errors.password_unchanged'),
      link: false
    }
    false
  end

  # Checks if +password+ and +confirmation+ password are same.
  # If not, add error messages to +error_object+.
  #
  # Returns a boolean.
  def correct_password_confirmation?
    return true if password == confirmation

    password_equality = I18n.t('password.errors.password_equality')
    @error_object = {
      base_message: password_equality,
      link: true,
      password: password_equality,
      password_confirmation: password_equality
    }
    false
  end
end
