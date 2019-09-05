# frozen_string_literal: true

module ApplicationHelper
  def current_path?(path)
    'govuk-header__navigation-item--active' if request.path_info == path
  end

  def service_name
    Rails.configuration.x.service_name
  end
end
