# frozen_string_literal: true

class ConfirmResetPasswordForm < BaseForm
  attr_reader :password, :confirmation, :code

  def initialize(password:, confirmation:, code:)
    @password = password
    @confirmation = confirmation
    @code = code
    super(nil)
  end

  def valid?
    filled_code? && filled_passwords? && correct_password_confirmation?
  end

  private

  def filled_code?
    return true if code.present?

    @message = I18n.t('password.errors.code_required')
    false
  end

  def filled_passwords?
    return true if password.present? && confirmation.present?

    @message = I18n.t('password.errors.password_required')
    false
  end

  def correct_password_confirmation?
    return true if password == confirmation

    @message = I18n.t('password.errors.password_equality')
    false
  end
end
