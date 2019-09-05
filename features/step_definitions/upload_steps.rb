# frozen_string_literal: true

def correlation_id
  SecureRandom.uuid
end

def job_name
  'ae67c64a-1d9e-459b-bde0-756eb73f36fe'
end

# Scenario: Upload a csv file and redirect to processing page
When('I upload a valid csv file') do
  allow(SecureRandom).to receive(:uuid).and_return(correlation_id)
  allow(CsvUploadService).to receive(:call).and_return(true)
  allow(RegisterCheckerApi).to receive(:register_job)
    .with('CAZ-2020-01-08-5.csv', correlation_id)
    .and_return(job_name)

  allow(RegisterCheckerApi).to receive(:job_status)
    .with(job_name, correlation_id).and_return('RUNNING')

  attach_file(:file, csv_file('CAZ-2020-01-08-5.csv'))
  click_button 'Upload'
end

When('I press refresh page link') do
  allow(RegisterCheckerApi).to receive(:job_status)
    .with(job_name, correlation_id).and_return('SUCCESS')

  click_link 'click here.'
end

Then('I am redirected to the Success page') do
  expect(page).to have_current_path(success_upload_index_path)
end

# Scenario: Upload a csv file and redirect to error page when api response not running or finished
When('I press refresh page link when api response not running or finished') do
  allow(RegisterCheckerApi).to receive(:job_status)
    .with(job_name, correlation_id).and_return('FAILURE')
  allow(RegisterCheckerApi).to receive(:job_errors)
    .with(job_name, correlation_id).and_return(['error'])
  click_link 'click here.'
end

#  Scenario: Upload a csv file whose name is not compliant with the naming rules
When('I upload a csv file whose name format is invalid') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-08.csv'))
  click_button 'Upload'
end

# Scenario: Upload a csv file format that is not .csv or .CSV
When('I upload a csv file whose format that is not .csv or .CSV') do
  attach_file(:file, empty_csv_file('CAZ-2020-01-08-4321.xlsx'))
  click_button 'Upload'
end

# Upload a valid csv file during error is encountered writing to S3
When('I upload a csv file during error on S3') do
  allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(false)

  attach_file(:file, csv_file('CAZ-2020-01-08-5.csv'))
  click_button 'Upload'
end

# Scenario: Show processing page without uploaded csv file
When('I want go to processing page') do
  visit processing_upload_index_path
end

def empty_csv_file(filename)
  File.join('spec', 'fixtures', 'files', 'csv', 'empty', filename)
end

def csv_file(filename)
  File.join('spec', 'fixtures', 'files', 'csv', filename)
end
