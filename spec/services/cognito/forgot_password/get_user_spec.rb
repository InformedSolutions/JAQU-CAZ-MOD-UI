# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::GetUser do
  subject(:service_call) { described_class.call(username: username) }

  let(:username) { 'user@example.com' }

  before do
    allow(Cognito::Client.instance).to receive(:admin_get_user).with(
      user_pool_id: anything,
      username: username
    ).and_return(true)
  end

  context 'with successful call' do
    it 'calls Cognito with proper params and returns true' do
      expect(Cognito::Client.instance).to receive(:admin_get_user).with(
        user_pool_id: anything,
        username: username
      ).and_return(true)
      service_call
    end
  end

  context 'when `Cognito::Client.instance.admin_get_user` call fails with proper params' do
    context 'and service raises `ServiceError`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_get_user).with(
          user_pool_id: anything,
          username: username
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
        )
      end

      it 'raises the `CallException`' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end

    context 'and service raises `UserNotFoundException`' do
      before do
        allow(Cognito::Client.instance).to receive(:admin_get_user).with(
          user_pool_id: anything,
          username: username
        ).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
        )
      end

      it 'raises the `CallException`' do
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
