# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::Lockout::UpdateUser do
  subject do
    described_class.call(
      username: username,
      failed_logins: failed_logins,
      lockout_time: lockout_time
    )
  end

  let(:username) { 'user@example.com' }
  let(:failed_logins) { 3 }
  let(:lockout_time) { Time.zone.now.iso8601 }

  let(:user_attributes) do
    [
      {
        name: 'custom:failed-logins',
        value: failed_logins.to_s
      },
      {
        name: 'custom:lockout-time',
        value: lockout_time.to_s
      }
    ]
  end

  before do
    allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).with(
      user_pool_id: anything,
      username: username,
      user_attributes: user_attributes
    ).and_return(true)
  end

  context 'with successful call' do
    it 'calls Cognito with proper params and returns true' do
      expect(Cognito::Client.instance).to receive(:admin_update_user_attributes).with(
        user_pool_id: anything,
        username: username,
        user_attributes: user_attributes
      ).and_return(true)
      subject
    end
  end

  context 'when `Cognito::Client.instance.admin_update_user_attributes`
           call fails with proper params' do
    context 'and service raises `ServiceError`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).with(
          user_pool_id: anything,
          username: username,
          user_attributes: user_attributes
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
        )
      end

      it 'raises the `CallException`' do
        expect { subject }.to raise_exception(Cognito::CallException)
      end
    end

    context 'and service raises `UserNotFoundException`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_update_user_attributes).with(
          user_pool_id: anything,
          username: username,
          user_attributes: user_attributes
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
        )
      end

      it 'raises the `CallException`' do
        expect { subject }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
