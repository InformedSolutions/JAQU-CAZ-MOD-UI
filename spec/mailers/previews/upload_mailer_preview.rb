# frozen_string_literal: true

##
# Preview all emails at http://localhost:3000/rails/mailers/upload_mailer
#
class UploadMailerPreview < ActionMailer::Preview
  def success_upload
    user = User.new
    user.email = 'test@example.com'
    time = Time.current.strftime(Rails.configuration.x.time_format)
    UploadMailer.success_upload(user, 'CAZ-2020-01-08-AuthorityID-1.csv', time)
  end
end
