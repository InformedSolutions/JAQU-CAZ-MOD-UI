# frozen_string_literal: true

class NewPasswordException < ApplicationException
  attr_reader :error_object

  def initialize(error_object = {})
    @error_object = error_object
    super(error_object[:base_message] || 'New password is invalid')
  end
end
