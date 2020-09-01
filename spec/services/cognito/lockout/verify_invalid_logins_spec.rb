# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::Lockout::VerifyInvalidLogins do
  subject { described_class.call(username: username) }

  let(:username) { 'user@example.com' }
  let(:user_response) do
    OpenStruct.new(
      user_attributes: [
        OpenStruct.new(name: 'custom:failed-logins', value: failed_logins),
        OpenStruct.new(name: 'custom:lockout-time', value: lockout_time)
      ]
    )
  end

  let(:failed_logins) { '0' }
  let(:lockout_time) { nil }

  let(:lockout_login_attempts) { ENV.fetch('LOCKOUT_LOGIN_ATTEMPTS', 5).to_i }
  let(:lockout_timeout) { ENV.fetch('LOCKOUT_TIMEOUT', 30).to_i }

  before do
    allow(Cognito::Client.instance).to receive(:admin_get_user).with(
      user_pool_id: anything,
      username: username
    ).and_return(user_response)
    allow(Cognito::Lockout::UpdateUser).to receive(:call).with(
      username: username,
      failed_logins: anything,
      lockout_time: anything
    )
    subject
  end

  context 'when user is not locked out and limit is not exceeded' do
    it 'increments invalid-logins attribute' do
      expect(Cognito::Lockout::UpdateUser)
        .to have_received(:call)
        .with(username: username, failed_logins: 1, lockout_time: nil)
    end
  end

  context 'when user is not locked out and limit is exceeded' do
    let(:failed_logins) { lockout_login_attempts.to_s }
    let(:lockout_time) { nil }

    it 'sets lockout-time attribute' do
      expect(Cognito::Lockout::UpdateUser)
        .to have_received(:call)
        .with(
          username: username,
          failed_logins: lockout_login_attempts,
          lockout_time: Time.zone.now.iso8601
        )
    end
  end

  context 'when user is locked out and lockout timeout is not exceeded' do
    let(:failed_logins) { lockout_login_attempts.to_s }
    let(:lockout_time) { Time.zone.now.iso8601 }

    it 'does not perform any update' do
      expect(Cognito::Lockout::UpdateUser).not_to have_received(:call)
    end
  end

  context 'when user is locked out and lockout timeout exceeded' do
    let(:failed_logins) { lockout_login_attempts.to_s }
    let(:lockout_time) { (lockout_timeout + 10).minutes.ago.iso8601 }

    it 'sets invalid-logins to 1 and lockout-time to nil' do
      expect(Cognito::Lockout::UpdateUser)
        .to have_received(:call)
        .with(username: username, failed_logins: 1, lockout_time: nil)
    end
  end
end
