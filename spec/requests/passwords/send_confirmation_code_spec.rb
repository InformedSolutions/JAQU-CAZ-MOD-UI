# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - POST #send_confirmation_code', type: :request do
  subject(:http_request) { post send_confirmation_code_passwords_path, params: params }

  let(:params) { { user: { username: username } } }
  let(:username) { 'wojtek' }

  context 'with password_reset_token set' do
    before do
      inject_session(password_reset_token: SecureRandom.uuid)
      allow(Cognito::ForgotPassword)
        .to receive(:call)
        .with(username: username)
        .and_return(true)
    end

    it 'redirects to confirm reset' do
      http_request
      expect(response).to redirect_to(confirm_reset_passwords_path)
    end

    it 'sets username in session' do
      http_request
      expect(session[:password_reset_username]).to eq(username)
    end

    context 'when service raises `ServiceError` exception' do
      let(:fallback_path) { reset_passwords_path }

      before do
        allow(Cognito::ForgotPassword)
          .to receive(:call)
          .with(username: username)
          .and_raise(Cognito::CallException.new('Something went wrong', fallback_path))
        http_request
      end

      it 'redirects to fallback path' do
        expect(response).to redirect_to(fallback_path)
      end
    end

    context 'when service raises `UserNotFoundException` exception' do
      before do
        allow(COGNITO_CLIENT).to receive(:forgot_password).and_raise(
          Aws::CognitoIdentityProvider::Errors::UserNotFoundException.new('', '')
        )
        http_request
      end

      it 'redirects to confirm reset' do
        expect(response).to redirect_to(confirm_reset_passwords_path)
      end
    end
  end

  context 'without password_reset_token set' do
    it 'returns redirect to success page' do
      http_request
      expect(response).to redirect_to(success_passwords_path)
    end
  end
end
