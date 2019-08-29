# frozen_string_literal: true

class NewPasswordForm
  attr_reader :password, :confirmation, :old_password_hash, :error_object

  def initialize(password:, confirmation:, old_password_hash:)
    @password = password
    @confirmation = confirmation
    @old_password_hash = old_password_hash
    @error_object = {}
  end

  def valid?
    filled? && password_changed? && correct_password_confirmation?
  end

  private

  def filled?
    return true if password.present? && confirmation.present?

    @error_object = {
      base_message: I18n.t('password.errors.passwords_required'),
      link: true,
      password: I18n.t('password.errors.password_required'),
      password_confirmation: I18n.t('password.errors.confirmation_required')
    }
    false
  end

  def password_changed?
    return true if old_password_hash && Digest::MD5.hexdigest(password) != old_password_hash

    @error_object = {
      base_message: I18n.t('password.errors.password_unchanged'),
      link: false
    }
    false
  end

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
