# frozen_string_literal: true

class BaseForm
  attr_reader :parameter, :message

  def initialize(parameter)
    @parameter = parameter
    @message = ''
  end
end
