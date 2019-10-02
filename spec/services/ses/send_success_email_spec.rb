# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ses::SendSuccessEmail do
  subject(:service_call) { described_class.call(user: user, job_data: job_data) }

  let(:user) { new_user(email: email) }
  let(:email) { 'user@example.com' }
  let(:job_data) { { filename: filename, submission_time: time } }
  let(:filename) { 'CAZ-2020-01-08-AuthorityID-1.csv' }
  let(:time) { Time.current.strftime(Rails.configuration.x.time_format) }

  context 'with valid params' do
    before do
      mailer = OpenStruct.new(deliver: true)
      allow(UploadMailer).to receive(:success_upload).and_return(mailer)
    end

    it { is_expected.to be_truthy }

    it 'sends an email with proper params' do
      expect(UploadMailer).to receive(:success_upload).with(user, filename, time)
      service_call
    end
  end

  context 'with invalid params' do
    before { allow(UploadMailer).to receive(:success_upload) }

    context 'when user email is missing' do
      let(:email) { nil }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        expect(UploadMailer).not_to receive(:success_upload)
        service_call
      end
    end

    context 'when filename is missing' do
      let(:filename) { nil }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        expect(UploadMailer).not_to receive(:success_upload)
        service_call
      end
    end

    context 'when submission time is missing' do
      let(:time) { nil }

      it { is_expected.to be_falsey }

      it 'does not call UploadMailer' do
        expect(UploadMailer).not_to receive(:success_upload)
        service_call
      end
    end
  end

  context 'when sending emails fails' do
    before do
      allow(UploadMailer).to receive(:success_upload).and_raise(
        Aws::SES::Errors::MessageRejected.new('', 'error')
      )
    end

    it { is_expected.to be_falsey }
  end
end
