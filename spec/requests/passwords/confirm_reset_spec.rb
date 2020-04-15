# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #confirm_reset', type: :request do
  subject(:http_request) { get confirm_reset_passwords_path }

  let(:username) { 'wojtek@example.com' }

  context 'with password_reset_token set' do
    before do
      inject_session(password_reset_token: SecureRandom.uuid, password_reset_username: username)
    end

    it 'returns 200' do
      http_request
      expect(response).to be_successful
    end
  end

  context 'without password_reset_token set' do
    it 'returns redirect to success page' do
      http_request
      expect(response).to redirect_to(success_passwords_path)
    end
  end

  context 'without password_reset_username set' do
    before do
      inject_session(password_reset_token: SecureRandom.uuid)
    end

    it 'returns redirect to login page' do
      http_request
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
