# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - POST #change', type: :request do
  subject(:http_request) { post change_passwords_path, params: params }

  let(:params) do
    {
      user: {
        username: username,
        password: password,
        confirmation_code: code,
        password_confirmation: password
      }
    }
  end
  let(:username) { 'wojtek' }
  let(:password) { 'password' }
  let(:code) { '123456' }

  context 'with password_reset_token set' do
    before do
      inject_session(password_reset_token: SecureRandom.uuid)
      allow(Cognito::ConfirmForgotPassword)
        .to receive(:call)
        .with(username: username,
              password: password,
              code: code,
              password_confirmation: password)
        .and_return(true)
    end

    it 'returns redirect to success page' do
      http_request
      expect(response).to redirect_to(success_passwords_path)
    end

    it 'clears password_reset_token' do
      http_request
      expect(session[:password_reset_token]).to be_nil
    end

    context 'when service raises exception' do
      let(:fallback_path) { reset_passwords_path }

      before do
        allow(Cognito::ConfirmForgotPassword)
          .to receive(:call)
          .and_raise(Cognito::CallException.new('Error', fallback_path))
      end

      it 'returns redirect to fallback path' do
        http_request
        expect(response).to redirect_to(fallback_path)
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
