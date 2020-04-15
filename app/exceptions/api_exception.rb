# frozen_string_literal: true

##
# This is an abstract class used as a base for all API exceptions.
#
class ApiException < StandardError
  # Attribute used internally to save values
  attr_reader :status, :status_message

  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +status+ - string or integer, HTTP error status
  # * +status_message+ - string, HTTP error message
  # * +message+ - string, error message
  # * +body+ - request body
  def initialize(status, status_message, body)
    @status         = status.to_i
    @status_message = status_message
    @message        = body['message'] if body.is_a?(Hash)
    @body           = body
  end

  ##
  # Displays error message from body with a status.
  #
  # ==== Example
  #
  #    "Status: 404; Message: 'Vehicle was not found'"
  def message
    "Status: #{status}; Message: #{@message || 'not received'}"
  end

  ##
  # Returns request body or an empty hash if there was no body.
  def body
    @body || {}
  end
end
