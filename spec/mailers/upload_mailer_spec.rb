# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadMailer, type: :mailer do
  let(:user) { new_user(email: email) }
  let(:email) { 'test@example.com' }

  describe '.success_upload' do
    subject(:mail) { described_class.success_upload(user, filename, time) }

    let(:filename) { 'CAZ-2020-01-08-AuthorityID-1.csv' }
    let(:time) { Time.current.strftime(Rails.configuration.x.time_format) }

    it { expect(mail.to).to include(email) }

    it 'renders filename' do
      expect(mail.body.encoded).to have_content(filename)
    end

    it 'renders submission time' do
      expect(mail.body.encoded).to have_content(time)
    end
  end
end
