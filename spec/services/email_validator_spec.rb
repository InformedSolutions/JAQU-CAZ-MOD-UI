# frozen_string_literal: true

require 'rails_helper'

describe EmailValidator do
  subject(:service_call) { described_class.call(email: email) }

  let(:email) { 'user@example.com' }

  describe '#validate' do
    context 'with valid params' do
      context 'when email is valid' do
        it 'returns nil' do
          expect(service_call).to be nil
        end
      end

      context 'when email is 45 characters length' do
        let(:email) { "#{SecureRandom.alphanumeric(35)}@email.com" }

        it 'returns nil' do
          expect(service_call).to be nil
        end
      end
    end

    context 'with invalid params' do
      context 'when email is too long' do
        let(:email) { "#{SecureRandom.alphanumeric(36)}@email.com" }

        it 'returns error message' do
          expect(service_call).to eq(I18n.t('email.errors.too_long'))
        end
      end

      context 'when invalid email format' do
        let(:email) { 'user.example.com' }

        it 'returns error message' do
          expect(service_call).to eq(I18n.t('email.errors.invalid_format'))
        end
      end
    end
  end
end
