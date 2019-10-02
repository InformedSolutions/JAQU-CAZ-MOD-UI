# frozen_string_literal: true

##
# Class used to create email sent to the user during CSV upload process
#
class UploadMailer < ApplicationMailer
  ##
  # Action sending an email to the user after successful file upload
  #
  # ==== Attributes
  #
  # * +user+ - an instance of {User class}[rdoc-ref:User] with an email address set
  # * +filename+ - string, name of the submitted file
  # * +submission_time+ - string, time of the file submission in a proper format
  #
  # ==== Usage
  #
  #    user = User.new
  #    user.email = 'test@example.com'
  #    filename = 'CAZ-2020-01-08-Leeds-1.csv'
  #    time = Time.current.strftime(Rails.configuration.x.time_format)
  #    UploadMailer.success_upload(user, filename, time).deliver
  #
  def success_upload(user, filename, submission_time)
    @filename = filename
    @submission_time = submission_time
    mail(to: user.email, subject: 'Upload successful')
  end
end
