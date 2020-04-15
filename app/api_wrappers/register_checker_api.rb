# frozen_string_literal: true

##
# This class wraps calls being made to the MOD backend API.
# The base URL for the calls is configured by +MOD_API_URL+ environment variable.
#
# All calls have the correlation ID and JSON content type added to the header.
#
# All methods are on the class level, so there is no initializer method.
class RegisterCheckerApi < BaseApi
  API_URL = ENV.fetch('MOD_API_URL', 'localhost:3001').freeze
  base_uri API_URL + '/v1/mod/register-csv-from-s3'

  class << self
    ##
    # Calls +/v1/mod/register-csv-from-s3/jobs+ endpoint with +POST+ method
    # and returns a job UUID
    #
    # ==== Attributes
    #
    # * +file_name+ - Csv file name, eg. 'CAZ-2020-01-08'
    # * +correlation_id+ - Correlation id, eg '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #
    # ==== Example
    #
    #    RegisterCheckerApi.register_job(
    #     'CAZ-2020-01-08',
    #     '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #    )
    #
    # ==== Result
    #
    # Returns a UUID, eg. '2ad47f86-8365-47ee-863b-dae6dbf69b3e'.
    #
    def register_job(file_name, correlation_id)
      log_call("Registering job with file name: #{file_name}")
      response = request(:post, '/jobs',
                         body: register_body(file_name),
                         headers: custom_headers(correlation_id))
      response['jobName']
    end

    ##
    # Calls +/v1/mod/register-csv-from-s3/jobs/:job_uuid+ endpoint with +GET+ method
    # and returns a job status.
    #
    # ==== Attributes
    #
    # * +job_uuid+ - Job UUID, eg '2ad47f86-8365-47ee-863b-dae6dbf69b3e'
    # * +correlation_id+ - Correlation id, eg '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #
    # ==== Example
    #
    #    RegisterCheckerApi.job_status(
    #     '2ad47f86-8365-47ee-863b-dae6dbf69b3e',
    #     '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #    )
    #
    # ==== Result
    #
    # Returns a job status, eg. 'SUCCESS'.
    #
    def job_status(job_uuid, correlation_id)
      log_call("Getting job status with job uuid: #{job_uuid}")
      response = request(:get, "/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      response['status']
    end

    ##
    # Calls +/v1/mod/register-csv-from-s3/jobs/:job_uuid+ endpoint with +GET+ method
    # and returns the error messages as an array.
    #
    # ==== Attributes
    #
    # * +job_uuid+ - Job UUID
    # * +correlation_id+ - Correlation id
    #
    # ==== Example
    #
    #    RegisterCheckerApi.job_errors(
    #     '2ad47f86-8365-47ee-863b-dae6dbf69b3e',
    #     '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #    )
    #
    # ==== Result
    #
    # Returns a nil if job status is not 'FAILURE'
    # Returns a array if job status is 'FAILURE', eg. '['error message one', error message two]'
    #
    def job_errors(job_uuid, correlation_id)
      log_call("Getting job errors with job uuid: #{job_uuid}")
      response = request(:get, "/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      return nil unless response['status'] == 'FAILURE'

      response['errors']
    end

    private

    ##
    # Returns a register body as a json.
    #
    # ==== Attributes
    #
    # * +file_name+ - Csv file name,  eg. 'CAZ-2020-01-08'
    #
    # ==== Result
    #
    # Returns a json,
    #   eg. "{\"filename\":\"CAZ-2020-01-08\",\"s3Bucket\":\"test-update-server\"}".
    #
    def register_body(file_name)
      {
        "filename": file_name,
        "s3Bucket": ENV.fetch('S3_AWS_BUCKET', 'S3_AWS_BUCKET')
      }.to_json
    end

    ##
    # Add the correlation ID and JSON content type to the header.
    #
    # ==== Attributes
    #
    # * +correlation_id+ - Correlation ID,  eg. '98faf123-d201-48cb-8fd5-4b30c1f80918'
    #
    # ==== Result
    #
    # Returns a json, eg. {
    #   "Content-Type"=>"application/json",
    #   "X-Correlation-ID"=>"d39337ca-d94b-4332-9219-12f5a14740f3"
    # }
    #
    def custom_headers(correlation_id)
      {
        'Content-Type' => 'application/json',
        'X-Correlation-ID' => correlation_id
      }
    end

    ##
    # Logs given message at +info+ level with a proper tag.
    #
    # ==== Attributes
    #
    # * +msg+ - string, log message
    #
    def log_call(msg)
      Rails.logger.info "[RegisterCheckerApi] #{msg}"
    end
  end
end
