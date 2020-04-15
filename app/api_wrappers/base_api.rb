# frozen_string_literal: true

##
# This is an abstract class used as a base for all API wrapper classes.
#
# It includes {HTTParty gem}[https://github.com/jnunemaker/httparty]
class BaseApi
  include HTTParty

  class << self
    ##
    # Performs a HTTP request and returns a hash with parsed body.
    #
    # ==== Attributes
    #
    # * +method+ - string or symbol, a valid HTTP request verb eg. +:get+
    # * +path+ - string, a path of a request eg. +'/users'+
    # * +options+ - hash, options like headers, the request body, query params
    #
    # ==== Exceptions
    #
    # Exception are raised based on HTTP status of the response.
    # Other HTTP statuses than 400, 404, 422 and errors during response parsing are treated as 500.
    #
    def request(method, path, options = {})
      response_object = public_send(method, path, options)
      validate_response(response_object.response)
    end

    private

    ##
    # Validates an API response and parses its body from JSON.
    # Returns a parsed JSON object to hash or
    # raises exception if status is above 400 or parsing fails.
    #
    def validate_response(response_struct)
      status = response_struct.code.to_i
      parsed_body = parse_body(response_struct.body)

      return parsed_body unless status.between?(400, 599)

      status_message = response_struct.msg
      raise ApiException.new(status, status_message, parsed_body)
    end

    ##
    # Parses response body and returns a hash.
    # +JSON::ParserError+ is treated as 500.
    #
    def parse_body(body)
      JSON.parse(body.presence || '{}')
    rescue JSON::ParserError
      Rails.logger.error "Error during parsing: #{body}"
      raise ApiException.new(500, 'Parse error', {})
    end
  end
end
