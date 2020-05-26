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

  # Used for external inline links in the app.
  # Returns a link with blank target and area-label.
  #
  # Reference: https://www.w3.org/WAI/GL/wiki/Using_aria-label_for_link_purpose
  def external_link_to(text, url, html_options = {})
    html_options.symbolize_keys!.reverse_merge!(
      target: '_blank',
      class: 'govuk-link',
      rel: 'noopener',
      'aria-label': "#{html_options[:'aria-label'] || text} (#{I18n.t('external_link')})"
    )

    link_to "#{text} (#{I18n.t('external_link')})", url, html_options
  end
end
