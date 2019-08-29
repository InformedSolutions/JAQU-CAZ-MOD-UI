# frozen_string_literal: true

module ApplicationHelper
  def current_path?(path)
    if (request.path_info == path) ||
       (request.path_info == root_path && path == upload_index_path)
      'govuk-header__navigation-item--active'
    end
  end

  def service_name
    Rails.configuration.x.service_name
  end
end
