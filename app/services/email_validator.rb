# frozen_string_literal: true

##
# This class is used to validate email address.
#
class EmailValidator < BaseService
  # Attribute used internally to save values.
  attr_reader :email

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +email+ - string, eg. 'example@email.com'
  def initialize(email:)
    @email = email
  end

  # The caller method for the service. It invokes validating.
  #
  # Returns a string if validation failed.
  def call
    if invalid_format?
      I18n.t('email.errors.invalid_format')
    elsif email_too_long?
      I18n.t('email.errors.too_long')
    end
  end

  private

  # Checks if email address not longer than 45 symbols.
  #
  # Returns boolean.
  def email_too_long?
    email.length > 45
  end

  # Checks if email address is compliant with the naming rules.
  #
  # Returns boolean.
  def invalid_format?
    (email =~ URI::MailTo::EMAIL_REGEXP).nil?
  end
end
