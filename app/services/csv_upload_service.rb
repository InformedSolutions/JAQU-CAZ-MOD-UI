# frozen_string_literal: true

class CsvUploadService < BaseService
  NAME_FORMAT = /^CAZ-([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))-\d+$/.freeze
  attr_reader :file, :error, :user

  def initialize(file:, user:)
    @file = file
    @user = user
    @error = nil
  end

  def call
    validate
    upload_to_s3
  end

  private

  def validate
    if no_file_selected? || invalid_extname? || invalid_filename?
      raise CsvUploadFailureException, error
    end
  end

  def no_file_selected?
    if file.nil?
      @error = I18n.t('csv.errors.no_file')
    end
  end

  def invalid_extname?
    unless File.extname(file.original_filename).downcase == '.csv'
      @error = I18n.t('csv.errors.invalid_ext')
    end
  end

  def invalid_filename?
    if File.basename(file.original_filename, '.*').match(NAME_FORMAT).nil?
      @error = I18n.t('csv.errors.invalid_name')
    end
  end

  def upload_to_s3
    Rails.logger.info "[S3Upload] Uploading file to s3 by a user: #{user.username}"
    return true if aws_call

    raise CsvUploadFailureException, I18n.t('csv.errors.base')
  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error e
    raise CsvUploadFailureException, I18n.t('csv.errors.base')
  end

  def aws_call
    s3_object = AMAZON_S3_CLIENT.bucket(bucket_name).object(file.original_filename)
    s3_object.upload_file(file, metadata: file_metadata)
  end

  def file_metadata
    { 'uploader-id': user.sub, 'csv-content-type': 'RETROFIT_LIST' }
  end

  def bucket_name
    ENV['S3_AWS_BUCKET']
  end
end
