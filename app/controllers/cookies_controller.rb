# frozen_string_literal: true

##
# Controller class for the cookies static page
#
class CookiesController < ApplicationController
  # assign back button path
  before_action :assign_back_button_url, only: %i[index]
  ##
  # Renders the static cookies page
  #
  # ==== Path
  #    GET /cookies
  #
  def index
    # renders static page
  end
end
