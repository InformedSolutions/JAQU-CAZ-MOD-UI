# frozen_string_literal: true

require 'rails_helper'

describe Cognito::ForgotPassword::RateLimitVerification do
  subject(:service_call) { described_class.call(username: username) }

  let(:username) { 'user@example.com' }

  let(:admin_get_user_response) do
    OpenStruct.new(user_attributes: [
                     OpenStruct.new(name: 'custom:pw-reset-counter', value: reset_counter),
                     OpenStruct.new(name: 'custom:pw-reset-requested', value: reset_requested)
                   ])
  end

  let(:reset_counter) { '0' }
  let(:reset_requested) { nil }

  before do
    allow(Cognito::Client.instance).to receive(:admin_get_user).with(
      user_pool_id: anything,
      username: username
    ).and_return(admin_get_user_response)

    allow(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(
      reset_counter: reset_counter,
      username: username
    ).and_return(true)
  end

  context 'when password reset counter no more than five' do
    it 'calls `Cognito::ForgotPassword::UpdateUser` with increased reset_counter' do
      expect(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(
        reset_counter: 1,
        username: username
      ).and_return(true)
      service_call
    end
  end

  context 'when password reset counter more than five' do
    let(:reset_counter) { '6' }

    context 'and request was made more than 1 hour ago' do
      let(:reset_requested) { (DateTime.current - 2.hours).to_i.to_s }

      it 'calls `Cognito::ForgotPassword::UpdateUser` and reset reset_counter to 1' do
        expect(Cognito::ForgotPassword::UpdateUser).to receive(:call).with(
          reset_counter: 1,
          username: username
        ).and_return(true)
        service_call
      end
    end

    context 'and request was made less than 1 hour ago' do
      let(:reset_requested) { (DateTime.current - 30.minutes).to_i.to_s }

      it 'dont reset reset_counter and raises exception with proper params ' do
        expect(Cognito::ForgotPassword::UpdateUser).to_not receive(:call)
        expect { service_call }.to raise_exception(Cognito::CallException, '') { |exception|
          exception.message.empty?
          exception.path == '/passwords/confirm_reset'
        }
      end
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
