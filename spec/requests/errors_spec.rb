# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :request do
  before { subject }

  describe '#not_found' do
    subject { get '/404.html' }

    it 'returns a not_found response' do
      expect(response).to have_http_status(:not_found)
    end

    it 'renders the view' do
      expect(response).to render_template(:not_found)
    end
  end

  describe '#internal_server_error' do
    subject { get '/500.html' }

    it 'returns a internal_server_error response' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the view' do
      expect(response).to render_template(:internal_server_error)
    end
  end

  describe 'Unprocessable Entity' do
    subject { get '/422.html' }

    it 'returns a internal_server_error response' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'renders the view' do
      expect(response).to render_template(:internal_server_error)
    end
  end
end
