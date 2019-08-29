# frozen_string_literal: true

require 'rails_helper'

describe 'Health check', type: :request do
  subject { get health_path }

  it 'returns 200' do
    subject
    expect(response).to be_successful
  end
end
