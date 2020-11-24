# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::UpdateUser do
  subject(:service_call) do
    described_class.call(
      reset_counter: reset_counter,
      username: username
    )
  end

  let(:reset_counter) { 0 }
  let(:username) { 'user@example.com' }
  let(:reset_requested) { nil }
  let(:current_date_time) { DateTime.current.to_i }

  let(:user_attributes) do
    [
      {
        name: 'custom:pw-reset-counter',
        value: reset_counter.to_s
      },
      {
        name: 'custom:pw-reset-requested',
        value: current_date_time.to_s
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
      service_call
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
        expect { service_call }.to raise_exception(Cognito::CallException)
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
        expect { service_call }.to raise_exception(Cognito::CallException)
      end
    end
  end
end
