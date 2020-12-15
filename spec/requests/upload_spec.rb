# frozen_string_literal: true

require 'rails_helper'

describe UploadController, type: :request do
  let(:file_path) { File.join('spec', 'fixtures', 'files', 'csv', 'CAZ-2020-01-08.csv') }
  let(:user) { new_user(email: 'test@example.com', authorized_list_type: 'green') }

  before { sign_in user }

  describe 'GET #index' do
    subject { get authenticated_root_path }

    it 'returns a success response' do
      subject
      expect(response).to have_http_status(:success)
    end

    context 'when session[:job] is set' do
      let(:correlation_id) { SecureRandom.uuid }
      let(:job_name) { 'name' }

      before do
        inject_session(job: { name: job_name, correlation_id: correlation_id })
        allow(RegisterCheckerApi).to receive(:job_errors).and_return(%w[error])
      end

      it 'calls RegisterCheckerApi.job_errors' do
        expect(RegisterCheckerApi).to receive(:job_errors).with(job_name, correlation_id)
        subject
      end

      it 'clears job from session' do
        subject
        expect(session[:job]).to be_nil
      end
    end

    context 'when user login IP does not match request IP' do
      let(:user) { new_user(login_ip: '0.0.0.0') }

      it 'returns a redirect to login page' do
        expect(subject).to redirect_to(new_user_session_path)
      end

      it 'logs out the user' do
        subject
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe 'POST #import' do
    subject { post import_upload_index_path, params: { file: csv_file } }

    let(:csv_file) { fixture_file_upload(file_path) }

    context 'with valid params' do
      before { allow(CsvUploadService).to receive(:call).and_return(true) }

      context 'and api returns 200 status' do
        before do
          allow(RegisterCheckerApi).to receive(:register_job).and_return(job_name)
          subject
        end

        let(:job_name) { 'name' }

        it 'returns a success response' do
          expect(response).to have_http_status(:found)
        end

        it 'sets job name in session' do
          expect(session[:job][:name]).to eq(job_name)
        end

        it 'sets filename in session' do
          expect(session[:job][:filename]).to eq(file_path.split('/').last)
        end
      end

      context 'and api returns 400 status' do
        before do
          allow(RegisterCheckerApi).to receive(:register_job).and_raise(
            BaseApi::Error400Exception.new(400, '', {})
          )
        end

        it 'renders the service unavailable page' do
          expect(subject).to render_template('errors/service_unavailable')
        end
      end
    end

    context 'with invalid params' do
      let(:file_path) do
        File.join('spec', 'fixtures', 'files', 'csv', 'empty', 'CAZ-2020-01-08-.csv')
      end

      it 'returns error' do
        subject
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
    subject { get processing_upload_index_path }

    let(:job_status) { 'SUCCESS' }
    let(:correlation_id) { SecureRandom.uuid }
    let(:job_name) { 'name' }
    let(:job_data) { { name: job_name, correlation_id: correlation_id } }

    context 'with valid job data' do
      before do
        inject_session(job: job_data)
        allow(RegisterCheckerApi).to receive(:job_status).and_return(job_status)
        subject
      end

      context 'when job status is SUCCESS' do
        it 'returns a redirect to success page' do
          expect(response).to redirect_to(success_upload_index_path)
        end
      end

      context 'when job status is RUNNING' do
        let(:job_status) { 'RUNNING' }

        it 'returns 200' do
          expect(response).to be_successful
        end

        it 'does not clear job from session' do
          expect(session[:job]).to eq(job_data)
        end
      end

      context 'when job status is FAILURE' do
        let(:job_status) { 'FAILURE' }

        it 'returns a redirect to upload page' do
          expect(response).to redirect_to(authenticated_root_path)
        end

        it 'does not clear job from session' do
          subject
          expect(session[:job]).to eq(job_data)
        end
      end
    end

    context 'with missing job data' do
      it 'returns a redirect to root page' do
        subject
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #success' do
    subject { get success_upload_index_path }

    context 'with empty session' do
      it 'returns 200' do
        subject
        expect(response).to be_successful
      end

      it 'does not call Ses::SendSuccessEmail' do
        expect(Ses::SendSuccessEmail).not_to receive(:call)
        subject
      end
    end

    context 'with job data is session' do
      let(:filename) { 'name.csv' }
      let(:time) { Time.current }
      let(:job_data) do
        {
          name: 'name',
          filename: filename,
          correlation_id: SecureRandom.uuid,
          submission_time: time
        }
      end

      before { inject_session(job: job_data) }

      context 'with successful call to Ses::SendSuccessEmail' do
        before { allow(Ses::SendSuccessEmail).to receive(:call).and_return(true) }

        it 'returns a 200 OK status' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'calls Ses::SendSuccessEmail' do
          expect(Ses::SendSuccessEmail).to receive(:call).with(user: user, job_data: job_data)
          subject
        end

        it 'clears job data from the session' do
          subject
          expect(session[:job]).to be_nil
        end

        it 'does not render the warning' do
          subject
          expect(response.body).not_to include(I18n.t('upload.delivery_error'))
        end
      end

      context 'with unsuccessful call to Ses::SendSuccessEmail' do
        before do
          allow(Ses::SendSuccessEmail).to receive(:call).and_return(false)
          subject
        end

        it 'returns a 200 OK status' do
          expect(response).to have_http_status(:ok)
        end

        it 'clears job data from the session' do
          expect(session[:job]).to be_nil
        end

        it 'renders the warning' do
          expect(response.body).to include(I18n.t('upload.delivery_error'))
        end
      end
    end
  end

  describe '#force_new_password' do
    subject { get authenticated_root_path }

    before do
      sign_in new_user(aws_status: 'FORCE_NEW_PASSWORD')
      subject
    end

    context 'when user aws_status is FORCE_NEW_PASSWORD' do
      it 'redirects to new password path' do
        expect(response).to redirect_to(new_password_path)
      end
    end
  end
end
