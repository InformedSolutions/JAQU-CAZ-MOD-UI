# frozen_string_literal: true

require 'rails_helper'

describe CsvUploadService do
  subject { described_class.call(file: file, user: user) }

  let(:file) { fixture_file_upload(csv_file('CAZ-2020-01-08.csv')) }
  let(:user) { new_user(authorized_list_type: 'green') }

  describe '#call' do
    context 'with valid params' do
      before { allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(true) }

      context 'and user on the green list' do
        it 'returns true' do
          expect(subject).to be true
        end

        context 'lowercase extension format' do
          let(:file) { fixture_file_upload(csv_file('CAZ-2020-01-08.csv')) }

          it 'returns true' do
            expect(subject).to be true
          end
        end

        context 'uppercase extension format' do
          let(:file) { fixture_file_upload(csv_file('CAZ-2020-01-08.CSV')) }

          it 'returns true' do
            expect(subject).to be true
          end
        end
      end

      context 'and user on the white list' do
        let(:user) { new_user(authorized_list_type: 'white') }

        it 'returns true' do
          expect(subject).to be true
        end
      end
    end

    context 'with invalid params' do
      context 'when `ValidateCsvService` returns error' do
        let(:file) { nil }

        it 'raises exception' do
          expect { subject }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when `S3UploadService` returns error' do
        before do
          allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(false)
        end

        it 'raises exception' do
          expect { subject }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when S3 raises an exception' do
        before do
          allow_any_instance_of(Aws::S3::Object)
            .to receive(:upload_file)
            .and_raise(Aws::S3::Errors::MultipartUploadError.new('', ''))
        end

        it 'raises a proper exception' do
          expect { subject }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when file is in the wrong format' do
        let(:file) { fixture_file_upload(empty_csv_file('CAZ-2020-01-08.xlsx')) }

        it 'raises exception' do
          expect { subject }.to raise_exception(CsvUploadFailureException)
        end
      end

      context 'when file size is too big' do
        let(:file) { fixture_file_upload(csv_file('CAZ-2020-01-08.csv')) }

        before { allow(file).to receive(:size).and_return(52_428_801) }

        it 'raises exception' do
          expect { subject }.to raise_exception(CsvUploadFailureException)
        end
      end
    end
  end

  describe 'name format regexp' do
    subject(:regexp) { described_class::NAME_FORMAT }

    it { is_expected.to match('CAZ-2018-01-08') }
    it { is_expected.not_to match('CAZ-2018-01-08-') }
  end
end
