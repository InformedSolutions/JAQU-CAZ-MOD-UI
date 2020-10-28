# frozen_string_literal: true

require 'rails_helper'

describe RegisterCheckerApi do
  let(:correlation_id) { SecureRandom.uuid }

  describe '.register_job' do
    subject { described_class.register_job(filename, correlation_id) }

    let(:filename) { 'random_file' }
    let(:job_name) { 'name' }

    before do
      stub_request(:post, %r{register-csv-from-s3/jobs})
        .with(
          headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id },
          body: {
            'filename': filename,
            's3Bucket': ENV.fetch('S3_AWS_BUCKET', 'S3_AWS_BUCKET')
          }.to_json
        ).to_return(status: 201, body: { jobName: job_name }.to_json)
    end

    it 'returns job name' do
      expect(subject).to eq(job_name)
    end

    context 'when body is an invalid JSON format' do
      before do
        stub_request(:post, %r{register-csv-from-s3/jobs})
          .with(
            headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id },
            body: {
              'filename': filename,
              's3Bucket': ENV.fetch('S3_AWS_BUCKET', 'S3_AWS_BUCKET')
            }.to_json
          ).to_return(status: 201, body: body)
      end

      let(:body) { 'invalid JSON format' }

      it 'raises Error500Exception' do
        expect { subject }.to raise_exception(
          an_instance_of(BaseApi::Error500Exception)
            .and(having_attributes(
                   status: 500,
                   status_message: 'Response body parsing failed',
                   body: body
                 ))
        )
      end
    end
  end

  describe 'get /register-csv-from-s3/jobs/:job_name' do
    let(:job_name) { 'name' }
    let(:job_status) { 'SUCCESS' }
    let(:job_errors) { [] }

    context 'when call returns 200' do
      before do
        stub_request(:get, %r{register-csv-from-s3/jobs/#{job_name}})
          .with(
            headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id }
          ).to_return(status: 200, body: { status: job_status, errors: job_errors }.to_json)
      end

      describe '.job_status' do
        it 'returns job status' do
          expect(described_class.job_status(job_name, correlation_id)).to eq(job_status)
        end
      end

      describe '.job_errors' do
        subject { described_class.job_errors(job_name, correlation_id) }

        context 'when status is not FAILURE' do
          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'when status is FAILURE' do
          let(:job_status) { 'FAILURE' }
          let(:job_errors) { %w[test test] }

          it 'returns errors' do
            expect(subject).to eq(job_errors)
          end
        end
      end
    end

    context 'when call returns 404' do
      before do
        stub_request(:get, %r{register-csv-from-s3/jobs/#{job_name}})
          .with(
            headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id }
          ).to_return(status: 404, body: { 'message' => '' }.to_json)
      end

      it 'raises `Error404Exception`' do
        expect { described_class.job_status(job_name, correlation_id) }
          .to raise_exception(BaseApi::Error404Exception)
      end
    end

    context 'when call returns 500' do
      before do
        stub_request(:get, %r{register-csv-from-s3/jobs/#{job_name}})
          .with(
            headers: { 'Content-Type' => 'application/json', 'X-Correlation-ID' => correlation_id }
          ).to_return(status: 500, body: { 'message' => '' }.to_json)
      end

      it 'raises `Error500Exception`' do
        expect { described_class.job_status(job_name, correlation_id) }
          .to raise_exception(BaseApi::Error500Exception)
      end
    end
  end
end
