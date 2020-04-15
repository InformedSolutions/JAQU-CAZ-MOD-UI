# frozen_string_literal: true

##
# Module used to send emails via AWS SES
#
module Ses
  ##
  # Sends an email to the user with successful CSV upload confirmation
  #
  # ==== Usage
  #    user = User.new
  #    user.email = 'test@example.com'
  #    time = Time.current.strftime(Rails.configuration.x.time_format)
  #    job_data = { filename: 'name.csv', submission_time: time }
  #    SendSuccessEmail.call(user: user, job_data: job_data)
  #
  class SendSuccessEmail < BaseService
    ##
    # Initializer method for the class. Used by class level method {call}[rdoc-ref:BaseService::call]
    #
    # ==== Attributes
    #
    # * +user+ - an instance of {User class}[rdoc-ref:User] with an email address set
    # * +job_data+ - hash with data about the upload job
    #   * +filename+ - string, name of the submitted file
    #   * +submission_time+ - string, time of the file submission as a string
    def initialize(user:, job_data:)
      @user = user
      @filename = job_data[:filename]
      @submission_time = job_data[:submission_time]
    end

    ##
    # Executing method for the class. Used by class level method {call}[rdoc-ref:BaseService::call]
    #
    # Returns true if sending email was successful, false if not. Rescues all the errors.
    #
    def call
      return false unless validate_params

      send_email
      true
    rescue StandardError => e
      log_error(e)
      false
    end

    private

    # Validates presence of params. Returns boolean.
    def validate_params
      return true if user.email.present? && filename.present? && submission_time.present?

      Rails.logger.error "[#{self.class.name}] Params are invalid - #{display_params}"
      false
    end

    # Calls the mailer class
    def send_email
      log_action("Sending :success_upload with #{display_params}")
      UploadMailer.success_upload(user, filename, submission_time).deliver
      log_action('Email sent successfully')
    end

    # Helper used to display params in logs
    def display_params
      "email: #{user.email}, filename: #{filename}, time: #{submission_time}"
    end

    # User instance
    attr_reader :user
    # Name of the submitted file
    attr_reader :filename
    # Time of the file submission
    attr_reader :submission_time
  end
end
