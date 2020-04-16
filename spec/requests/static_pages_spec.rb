# frozen_string_literal: true

require 'rails_helper'

describe StaticPagesController, type: :request do
  subject(:http_request) { get '/' }

  before do
    sign_in User.new
    http_request
  end

  describe 'GET #cookies' do
    subject(:http_request) { get cookies_path }

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #accessibility_statement' do
    subject(:http_request) { get accessibility_statement_path }

    it 'returns a success response' do
      expect(response).to have_http_status(:success)
    end
  end
end
