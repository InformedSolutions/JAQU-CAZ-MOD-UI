# frozen_string_literal: true

class BaseApi
  include HTTParty

  class << self
    def request(method, path, options = {})
      response_object = public_send(method, path, options)
      validate_response(response_object.response)
    end

    private

    def validate_response(response_struct)
      status = response_struct.code.to_i
      parsed_body = parse_body(response_struct.body)

      return parsed_body unless status.between?(400, 599)

      status_message = response_struct.msg
      raise ApiException.new(status, status_message, parsed_body)
    end

    def parse_body(body)
      JSON.parse(body.presence || '{}')
    rescue JSON::ParserError
      raise ApiException.new(500, 'Parse error', {})
    end
  end
end
