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
  let(:username) { 'wojtek@example.com' }
  let(:password) { 'password' }
  let(:code) { '123456' }

  context 'with password_reset_token set' do
    before do
      inject_session(
        password_reset_token: SecureRandom.uuid,
        password_reset_username: username
      )
      allow(Cognito::ForgotPassword::Confirm)
        .to receive(:call)
        .with(username: username,
              password: password,
              code: code,
              password_confirmation: password)
        .and_return(true)
      allow(Cognito::ForgotPassword::UpdateUser)
        .to receive(:call).with(reset_counter: 1, username: username)
                          .and_return(true)
      allow(Cognito::Lockout::UpdateUser)
        .to receive(:call).with(username: username, failed_logins: 0)
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

    it 'clears password_reset_username' do
      http_request
      expect(session[:password_reset_username]).to be_nil
    end

    it 'updates user lockout data' do
      http_request
      expect(Cognito::Lockout::UpdateUser).to have_received(:call)
        .with(username: username, failed_logins: 0)
    end

    context 'when service raises exception' do
      before do
        allow(Cognito::ForgotPassword::Confirm)
          .to receive(:call)
          .and_raise(Cognito::CallException.new('Error'))
      end

      it 'returns redirect to confirm_reset_passwords_path' do
        http_request
        expect(response).to redirect_to(confirm_reset_passwords_path)
      end

      it 'does not update user lockout data' do
        http_request
        expect(Cognito::Lockout::UpdateUser).not_to have_received(:call)
      end
    end

    context 'when `COGNITO.admin_update_user_attributes` service raises exception' do
      before do
        allow(Cognito::ForgotPassword::UpdateUser)
          .to receive(:call)
          .and_raise(Cognito::CallException.new('Something went wrong'))
      end

      it 'returns redirect to confirm_reset_passwords_path' do
        http_request
        expect(response).to redirect_to(confirm_reset_passwords_path)
      end

      it 'does not update user lockout data' do
        http_request
        expect(Cognito::Lockout::UpdateUser).not_to have_received(:call)
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
