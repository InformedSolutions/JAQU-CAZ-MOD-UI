# frozen_string_literal: true

class RegisterCheckerApi < BaseApi
  base_uri ENV['MOD_API_URL']

  class << self
    def register_job(file_name, correlation_id)
      log_call("Registering job with file name: #{file_name}")
      response = request(:post, "#{base_path}/jobs",
                         body: register_body(file_name),
                         headers: custom_headers(correlation_id))
      response['jobName']
    end

    def job_status(job_uuid, correlation_id)
      log_call("Getting job status with job uuid: #{job_uuid}")
      response = request(:get, "#{base_path}/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      response['status']
    end

    def job_errors(job_uuid, correlation_id)
      log_call("Getting job errors with job uuid: #{job_uuid}")
      response = request(:get, "#{base_path}/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      return nil unless response['status'] == 'FAILURE'

      response['errors']
    end

    private

    def register_body(file_name)
      {
        "filename": file_name,
        "s3Bucket": ENV['S3_AWS_BUCKET']
      }.to_json
    end

    def custom_headers(correlation_id)
      {
        'Content-Type' => 'application/json',
        'X-Correlation-ID' => correlation_id
      }
    end

    def base_path
      '/v1/mod/register-csv-from-s3'
    end

    def log_call(msg)
      Rails.logger.info "[RegisterCheckerApi] #{msg}"
    end
  end
end
