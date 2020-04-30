# frozen_string_literal: true

##
# This class is used to upload csv file to AWS S3.
#
class CsvUploadService < BaseService
  # regular expression for validating filename.
  NAME_FORMAT = /^CAZ-([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))+$/.freeze
  ##
  # Initializer method.
  #
  # ==== Attributes
  #
  # * +file+ - uploaded file
  # * +user+ - an instance of the User class
  # * +error+ - nil, default error message
  def initialize(file:, user:)
    @file = file
    @user = user
    @error = nil
  end

  # The caller method for the service. It invokes validating and uploading file to AWS S3
  #
  # Returns a boolean
  def call
    validate
    upload_to_s3
  end

  private

  # Validates a csv file.
  #
  # Raises exception if at least one validation not returns true.
  #
  # Returns a boolean.
  def validate
    if no_file_selected? || invalid_extname? || invalid_filename?
      raise CsvUploadFailureException, error
    end
  end

  # Checks if file is present.
  # If not, add error message to +error+.
  #
  # Returns a boolean if file is present.
  # Returns a string if not.
  def no_file_selected?
    if file.nil?
      @error = I18n.t('csv.errors.no_file')
    end
  end

  # Checks if filename extension equals `csv`.
  # If not, add error message to +error+.
  #
  # Returns a boolean if filename extension equals `csv`.
  # Returns a string if not.
  def invalid_extname?
    unless File.extname(file.original_filename).downcase == '.csv'
      @error = I18n.t('csv.errors.invalid_ext')
    end
  end

  # Checks if filename is compliant with the naming rules.
  # If not, add error message to +error+.
  #
  # Returns a boolean if filename is compliant with the naming rules
  # Returns a string if not.
  def invalid_filename?
    if File.basename(file.original_filename, '.*').match(NAME_FORMAT).nil?
      @error = I18n.t('csv.errors.invalid_name')
    end
  end

  # Uploading file to AWS S3.
  #
  # Raise exception if upload failed
  #
  # Returns a boolean.
  def upload_to_s3
    log_action 'Uploading file to S3'
    return true if aws_call

    raise CsvUploadFailureException, I18n.t('csv.errors.base')
  rescue Aws::S3::Errors::ServiceError => e
    log_error e
    raise CsvUploadFailureException, I18n.t('csv.errors.base')
  end

  # Uploading file to AWS S3.
  #
  # Returns a boolean.
  def aws_call
    s3_object = AMAZON_S3_CLIENT.bucket(bucket_name).object(file.original_filename)
    s3_object.upload_file(file, metadata: file_metadata)
  end

  # Returns a hash.
  def file_metadata
    { 'uploader-id': user.sub, 'csv-content-type': adjusted_list_type }
  end

  # Returns a string.
  def adjusted_list_type
    if user.authorized_list_type == 'green'
      'MOD_GREEN_LIST'
    else
      'MOD_WHITE_LIST'
    end
  end

  # AWS S3 Bucket Name.
  #
  # Returns a string.
  def bucket_name
    ENV.fetch('S3_AWS_BUCKET', 'S3_AWS_BUCKET')
  end

  # Attributes used internally to save values.
  attr_reader :file, :error, :user
end
