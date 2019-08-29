# frozen_string_literal: true

require 'rails_helper'

describe 'PasswordsController - GET #reset', type: :request do
  let(:user) { User.new }

  subject(:http_request) { get reset_passwords_path }

  it 'returns 200' do
    http_request
    expect(response).to be_successful
  end

  it 'sets password_reset_token' do
    http_request
    expect(session[:password_reset_token]).not_to be_nil
  end
end
