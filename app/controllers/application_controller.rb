# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  rescue_from CsvUploadFailureException, with: :handle_exception

  def health
    render json: 'OK', status: :ok
  end

  def build_id
    render json: ENV.fetch('BUILD_ID', 'undefined'), status: :ok
  end

  private

  def handle_exception(exception)
    redirect_to(upload_index_path, alert: exception.message)
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end
end
