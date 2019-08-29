# frozen_string_literal: true

module Cognito
  class CallException < RuntimeError
    attr_reader :path

    def initialize(msg, path = nil)
      @path = path
      super(msg)
    end
  end
end
