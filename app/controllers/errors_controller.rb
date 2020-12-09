# frozen_string_literal: true

##
# Controller class for rendering custom error pages.
# HTML response is returned for all types of requests.
#
class ErrorsController < ApplicationController
  before_action :set_html_response_format

  ##
  # Renders 404 error page.
  #
  # The view is based on {this pattern}[https://design-system.service.gov.uk/patterns/page-not-found-pages/] from Design System.
  def not_found
    render(status: :not_found)
  end

  ##
  # Renders 500 error page
  #
  # The view is based on {this pattern}[https://design-system.service.gov.uk/patterns/problem-with-the-service-pages/] from Design System.
  def internal_server_error
    render(status: :internal_server_error)
  end

  ##
  # Renders 503 error page
  #
  # The view is based on {this pattern}[https://design-system.service.gov.uk/patterns/service-unavailable-pages/] from Design System.
  def service_unavailable
    render(status: :service_unavailable)
  end

  private

  # Changes the request format to HTML to always display the error pages
  def set_html_response_format
    request.format = :html
  end
end
