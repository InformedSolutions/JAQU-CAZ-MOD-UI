# frozen_string_literal: true

require 'rails_helper'

describe 'Build ID', type: :request do
  subject { get build_id_path }

  it 'returns 200' do
    subject
    expect(response).to be_successful
  end

  it 'returns undefined' do
    subject
    expect(response.body).to eq('undefined')
  end

  context 'when BUILD_ID is defined' do
    let(:build_id) { '50.0' }

    before do
      allow(ENV).to receive(:fetch).with('BUILD_ID', 'undefined').and_return(build_id)
    end

    it 'returns BUILD_ID' do
      subject
      expect(response.body).to eq(build_id)
    end
  end
end
