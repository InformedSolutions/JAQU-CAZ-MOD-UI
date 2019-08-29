# frozen_string_literal: true

class ResetPasswordForm < BaseForm
  def valid?
    filled? && valid_format?
  end

  private

  def filled?
    return true if parameter.present?

    @message = I18n.t('email.errors.required')
    false
  end

  def valid_format?
    error = EmailValidator.call(email: parameter)
    return true unless error

    @message = error
    false
  end
end
