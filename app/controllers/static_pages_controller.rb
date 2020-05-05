# frozen_string_literal: true

##
# Controller class for the static pages
#
class StaticPagesController < ApplicationController
  # assign back button path
  before_action :assign_back_button_url

  ##
  # Renders the accessibility statement page
  #
  # ==== Path
  #    GET /accessibility_statement
  #
  def accessibility_statement
    # renders static page
  end

  ##
  # Renders the cookies page
  #
  # ==== Path
  #    GET /cookies
  #
  def cookies
    # renders static page
  end
end
