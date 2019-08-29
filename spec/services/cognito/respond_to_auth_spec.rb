# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::RespondToAuthChallenge do
  subject(:service_call) do
    described_class.call(user: user, password: password, confirmation: password_confirmation)
  end

  let(:password) { 'password' }
  let(:password_confirmation) { password }

  let(:user) do
    new_user(
      username: 'wojtek',
      aws_session: SecureRandom.uuid,
      hashed_password: Digest::MD5.hexdigest('temporary_password')
    )
  end

  let(:cognito_user) do
    new_user(username: 'wojciech')
  end

  let(:auth_response) do
    OpenStruct.new(authentication_result: OpenStruct.new(access_token: token))
  end
  let(:token) { SecureRandom.uuid }

  before do
    allow(Cognito::GetUser).to receive(:call)
      .with(access_token: token, user: user)
      .and_return(cognito_user)
    allow(COGNITO_CLIENT).to receive(:respond_to_auth_challenge)
      .with(
        challenge_name: 'NEW_PASSWORD_REQUIRED',
        client_id: anything,
        session: user.aws_session,
        challenge_responses: {
          'NEW_PASSWORD' => password,
          'USERNAME' => user.username
        }
      ).and_return(auth_response)
  end

  it 'returns a cggnito user' do
    expect(service_call).to eq(cognito_user)
  end

  context 'when NewPasswordForm returns invalid' do
    let(:form) { OpenStruct.new(valid?: false, error_object: {}) }
    let(:error) { I18n.t('password.errors.password_unchanged') }

    before do
      allow(NewPasswordForm).to receive(:new).and_return(form)
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(NewPasswordException)
    end
  end

  context 'when Cognito returns InvalidPasswordException' do
    let(:error) { I18n.t('password.errors.complexity') }

    before do
      allow(COGNITO_CLIENT).to receive(:respond_to_auth_challenge).and_raise(
        Aws::CognitoIdentityProvider::Errors::InvalidPasswordException.new('', '')
      )
    end

    it 'raises the new password exception' do
      expect { service_call }.to raise_exception(NewPasswordException)
    end
  end

  context 'when Cognito returns other exception' do
    let(:error) { I18n.t('expired_session') }

    before do
      allow(COGNITO_CLIENT).to receive(:respond_to_auth_challenge).and_raise(
        Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
      )
    end

    it 'raises exception' do
      expect { service_call }.to raise_exception(Cognito::CallException, error)
    end
  end
end
