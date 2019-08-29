# frozen_string_literal: true

class ErrorsController < ApplicationController
  before_action :set_html_response_format

  def not_found
    render(status: :not_found)
  end

  def internal_server_error
    render(status: :internal_server_error)
  end

  private

  def set_html_response_format
    request.format = :html
  end
end
