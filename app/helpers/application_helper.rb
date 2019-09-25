# frozen_string_literal: true

##
# Base module for helpers, generated automatically during new application creation.
#
module ApplicationHelper
  # Returns a 'govuk-header__navigation-item--active' if current path equals a new path.
  def current_path?(path)
    'govuk-header__navigation-item--active' if request.path_info == path
  end

  # Returns name of service, eg. 'Taxi and PHV Data Portal'.
  def service_name
    Rails.configuration.x.service_name
  end
end
