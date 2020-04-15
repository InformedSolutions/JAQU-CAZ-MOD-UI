# frozen_string_literal: true

##
# Raises exception if invalid password was provided.
#
class NewPasswordException < ApplicationException
  # Attribute used internally to save values
  attr_reader :error_object

  ##
  # Initializer method for the class. Calls +super+ method on parent class (ApplicationException).
  #
  # ==== Attributes
  # * +error_object+ - hash - messaged passed to parent exception
  def initialize(error_object = {})
    @error_object = error_object
    super(error_object[:base_message] || 'New password is invalid')
  end
end
