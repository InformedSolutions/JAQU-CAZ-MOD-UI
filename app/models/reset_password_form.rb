# frozen_string_literal: true

##
# This class is used to validate user data filled in +app/views/passwords/reset.html.haml+.
class ResetPasswordForm < BaseForm
  ##
  # Validate user data.
  #
  # Returns a boolean.
  def valid?
    filled? && valid_format?
  end

  private

  # Checks if +email+ was entered.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def filled?
    return true if parameter.present?

    @message = I18n.t('email.errors.required')
    false
  end

  # Checks if +email+ format is valid.
  # If not, add error message to +message+.
  #
  # Returns a boolean.
  def valid_format?
    error = EmailValidator.call(email: parameter)
    return true unless error

    @message = error
    false
  end
end
