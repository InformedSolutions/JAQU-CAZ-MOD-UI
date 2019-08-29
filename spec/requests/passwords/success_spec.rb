# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #success', type: :request do
  subject(:http_request) { get success_passwords_path }

  context 'when user is logged in' do
    before do
      sign_in new_user
      http_request
    end

    it 'returns 200' do
      expect(response).to be_successful
    end
  end

  context 'when user is not logged in' do
    before { http_request }

    it 'returns 200' do
      expect(response).to be_successful
    end
  end
end
