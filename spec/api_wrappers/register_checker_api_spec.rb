# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegisterCheckerApi do
  let(:correlation_id) { SecureRandom.uuid }

  describe '.register_job' do
    subject(:api_call) { described_class.register_job(filename, correlation_id) }

    let(:filename) { 'random_file' }
    let(:job_name) { 'name' }

    before do
      stub_request(:post, %r{register-csv-from-s3/jobs})
        .with(
          headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id },
          body: { "filename": filename, "s3Bucket": ENV['S3_AWS_BUCKET'] }.to_json
        ).to_return(status: 201, body: { jobName: job_name }.to_json)
    end

    it 'returns job name' do
      expect(api_call).to eq(job_name)
    end
  end

  describe 'get /register-csv-from-s3/jobs/:job_name' do
    let(:job_name) { 'name' }
    let(:job_status) { 'SUCCESS' }
    let(:job_errors) { [] }

    before do
      stub_request(:get, %r{register-csv-from-s3/jobs/#{job_name}})
        .with(
          headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id }
        ).to_return(status: 200, body: { status: job_status, errors: job_errors }.to_json)
    end

    describe '.job_status' do
      subject(:api_call) { described_class.job_status(job_name, correlation_id) }

      it 'returns job status' do
        expect(api_call).to eq(job_status)
      end
    end

    describe '.job_errors' do
      subject(:api_call) { described_class.job_errors(job_name, correlation_id) }

      context 'when status is not FAILURE' do
        it 'returns nil' do
          expect(api_call).to be_nil
        end
      end

      context 'when status is FAILURE' do
        let(:job_status) { 'FAILURE' }
        let(:job_errors) { %w[test test] }

        it 'returns errors' do
          expect(api_call).to eq(job_errors)
        end
      end
    end
  end
end
