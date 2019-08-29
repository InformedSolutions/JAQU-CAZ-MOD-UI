# frozen_string_literal: true

require 'rails_helper'

describe UploadController, type: :request do
  let(:file_path) do
    File.join(
      'spec',
      'fixtures', 'files', 'csv', 'CAZ-2020-01-08-5.csv'
    )
  end

  before :each do
    sign_in User.new
  end

  describe 'GET #index' do
    subject(:http_request) { get upload_index_path }

    it 'returns a success response' do
      http_request
      expect(response).to have_http_status(:success)
    end

    context 'when session[:job] is set' do
      let(:correlation_id) { SecureRandom.uuid }
      let(:job_name) { 'name' }

      before do
        inject_session(job: { name: job_name, correlation_id: correlation_id })
        allow(RegisterCheckerApi).to receive(:job_errors).and_return(['error'])
      end

      it 'calls RegisterCheckerApi.job_errors' do
        expect(RegisterCheckerApi).to receive(:job_errors).with(job_name, correlation_id)
        http_request
      end

      it 'clears job from session' do
        http_request
        expect(session[:job]).to be_nil
      end
    end
  end

  describe 'POST #import' do
    subject(:http_request) do
      post import_upload_index_path, params: { file: csv_file }
    end

    let(:csv_file) { fixture_file_upload(file_path) }

    context 'with valid params' do
      let(:job_name) { 'name' }
      before do
        allow(CsvUploadService).to receive(:call).and_return(true)
        allow(RegisterCheckerApi).to receive(:register_job).and_return(job_name)
        http_request
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:found)
      end

      it 'sets job name in session' do
        expect(session[:job][:name]).to eq(job_name)
      end
    end

    context 'with invalid params' do
      let(:file_path) do
        File.join('spec', 'fixtures', 'files', 'csv', 'empty', 'CAZ-2020-01-08.csv')
      end

      it 'returns error' do
        http_request
        follow_redirect!
        expect(response.body).to include('The selected file must be named correctly')
      end
    end
  end

  describe 'GET #data_rules' do
    subject(:http_request) { get data_rules_upload_index_path }

    it 'returns a success response' do
      http_request
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #processing' do
    subject(:http_request) { get processing_upload_index_path }

    let(:job_status) { 'SUCCESS' }
    let(:correlation_id) { SecureRandom.uuid }
    let(:job_name) { 'name' }
    let(:job_data) { { name: job_name, correlation_id: correlation_id } }

    context 'with valid job data' do
      before do
        inject_session(job: job_data)
        allow(RegisterCheckerApi).to receive(:job_status).and_return(job_status)
        http_request
      end

      context 'when job status is SUCCESS' do
        it 'returns a redirect to success page' do
          expect(response).to redirect_to(success_upload_index_path)
        end

        it 'clears job from session' do
          http_request
          expect(session[:job]).to be_nil
        end
      end

      context 'when job status is RUNNING' do
        let(:job_status) { 'RUNNING' }

        it 'returns 200' do
          expect(response).to be_successful
        end

        it 'does not clear job from session' do
          http_request
          expect(session[:job]).to eq(job_data)
        end
      end

      context 'when job status is FAILURE' do
        let(:job_status) { 'FAILURE' }

        it 'returns a redirect to upload page' do
          expect(response).to redirect_to(upload_index_path)
        end

        it 'does not clear job from session' do
          http_request
          expect(session[:job]).to eq(job_data)
        end
      end
    end

    context 'with missing job data' do
      it 'returns a redirect to root page' do
        http_request
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
