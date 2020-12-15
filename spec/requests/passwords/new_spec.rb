# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #new' do
  subject { get new_password_path }

  before do
    sign_in user
    subject
  end

  context 'when user aws_status is OK' do
    let(:user) { new_user }

    it 'returns a redirect to root_path' do
      expect(response).to redirect_to(root_path)
    end
  end

  context 'when user aws_session is missing' do
    let(:user) { new_user(aws_status: 'FORCE_NEW_PASSWORD') }

    it 'returns a redirect to new_user_session_path' do
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with valid params' do
    let(:user) do
      new_user(aws_status: 'FORCE_NEW_PASSWORD', aws_session: SecureRandom.uuid)
    end

    it 'returns a 200 OK status' do
      expect(response).to have_http_status(:ok)
    end
  end
end
