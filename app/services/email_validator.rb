# frozen_string_literal: true

class EmailValidator < BaseService
  attr_reader :email

  def initialize(email:)
    @email = email
  end

  def call
    if invalid_format?
      I18n.t('email.errors.invalid_format')
    elsif email_too_long?
      I18n.t('email.errors.too_long')
    end
  end

  private

  def email_too_long?
    email.length > 45
  end

  def invalid_format?
    (email =~ URI::MailTo::EMAIL_REGEXP).nil?
  end
end
