# frozen_string_literal: true

require 'rails_helper'

describe 'User singing in', type: :request do
  let(:email) { 'user@example.com' }
  let(:password) { '12345678' }
  let(:params) do
    {
      user: {
        username: email,
        password: password
      }
    }
  end

  describe 'signing in' do
    subject(:http_request) { post user_session_path(params) }

    context 'when incorrect credentials given' do
      before do
        expect(Cognito::Client.instance).to receive(:initiate_auth)
          .and_raise(
            Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new('', 'error')
          )
      end

      it 'shows `The username or password you entered is incorrect` message' do
        http_request
        expect(response.body).to include(I18n.t('devise.failure.invalid'))
      end
    end

    context 'when another error occurs' do
      before do
        allow(Cognito::Client.instance).to receive(:initiate_auth)
          .and_raise(
            Aws::CognitoIdentityProvider::Errors::InternalErrorException.new('', 'error')
          )
      end

      it 'shows `The username or password you entered is incorrect` message' do
        http_request
        expect(response.body).to include(I18n.t('devise.failure.invalid'))
      end
    end

    context 'when correct credentials given' do
      before do
        user_with_list_type = new_user(authorized_list_type: 'green')
        allow(Cognito::AuthUser).to receive(:call).and_return(user_with_list_type)
      end

      it 'logs user in' do
        http_request
        expect(controller.current_user).not_to be(nil)
      end

      it 'redirects to root' do
        http_request
        expect(response).to redirect_to(root_path)
      end

      it 'calls Cognito::AuthUser with proper params' do
        expect(Cognito::AuthUser)
          .to receive(:call)
          .with(username: email, password: password, login_ip: @remote_ip)
        http_request
      end
    end
  end
end
