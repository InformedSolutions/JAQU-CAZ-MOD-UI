# frozen_string_literal: true

##
# Base class for mailers. Sets default from value and layout
#
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
