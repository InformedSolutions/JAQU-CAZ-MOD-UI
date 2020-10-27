# frozen_string_literal: true

require 'rails_helper'

describe 'User singing in' do
  let(:email) { 'user@example.com' }
  let(:password) { '12345678' }
  let(:params) { { user: { username: email, password: password } } }

  describe 'signing in' do
    subject { post user_session_path(params) }

    context 'when correct credentials given' do
      before do
        user_with_list_type = new_user(authorized_list_type: 'green')
        allow(Cognito::AuthUser).to receive(:call).and_return(user_with_list_type)
      end

      it 'logs user in' do
        subject
        expect(controller.current_user).not_to be(nil)
      end

      it 'redirects to root' do
        subject
        expect(response).to redirect_to(root_path)
      end

      it 'calls Cognito::AuthUser with proper params' do
        expect(Cognito::AuthUser)
          .to receive(:call)
          .with(username: email, password: password, login_ip: @remote_ip)
        subject
      end
    end

    context 'when email and password are empty' do
      before { subject }

      let(:email) { '' }
      let(:password) { '' }

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when incorrect credentials given' do
      before do
        allow(Cognito::AuthUser).to receive(:call).and_return(false)
        subject
      end

      it 'shows `The username or password you entered is incorrect` message' do
        expect(response.body).to include(I18n.t('devise.failure.invalid'))
      end
    end

    context 'when email is an invalid format' do
      let(:email) { 'invalid_email_format' }

      before { subject }

      it 'provides proper error messages' do
        errors = { email: 'Enter your email address in a valid format', password: 'Enter your password' }
        expect(flash[:errors]).to eq(errors)
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
