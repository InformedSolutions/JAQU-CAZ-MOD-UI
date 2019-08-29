# frozen_string_literal: true

class ApiException < StandardError
  attr_reader :status, :status_message

  def initialize(status, status_message, body)
    @status         = status.to_i
    @status_message = status_message
    @message        = body['message'] if body.is_a?(Hash)
    @body           = body
  end

  def message
    "Status: #{status}; Message: #{@message || 'not received'}"
  end

  def body
    @body || {}
  end
end
