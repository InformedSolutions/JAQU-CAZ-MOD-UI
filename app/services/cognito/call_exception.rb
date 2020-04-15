# frozen_string_literal: true

module Cognito
  ##
  # Exception raised as the result of other exceptions that may occur during performing Cognito calls.
  # Usually rescued on the controller level.
  #
  class CallException < RuntimeError
    # The path which controller should redirect to after encountering this exception.
    # Valid URL, optional
    attr_reader :path

    ##
    # Initializer method for the class. Calls +super+ method on parent class (RuntimeError)
    #
    # ==== Attributes
    # * +msg+ - string - messaged passed to parent exception
    # * +path+ - URL, optional - path which controller should redirect
    def initialize(msg, path = nil)
      @path = path
      super(msg)
    end
  end
end
