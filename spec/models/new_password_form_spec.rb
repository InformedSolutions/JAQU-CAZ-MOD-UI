# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewPasswordForm, type: :model do
  subject(:form) do
    described_class.new(
      password: password, confirmation: confirmation, old_password_hash: old_password_hash
    )
  end

  let(:password) { 'password' }
  let(:confirmation) { password }
  let(:old_password_hash) { Digest::MD5.hexdigest('old_password') }

  it 'is valid with a proper password' do
    expect(form).to be_valid
  end

  context 'when password is empty' do
    let(:password) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    describe 'error object' do
      before { form.valid? }

      it 'has a proper base message' do
        expect(form.error_object[:base_message])
          .to eq(I18n.t('password.errors.passwords_required'))
      end

      it 'has a display link set to true' do
        expect(form.error_object[:link]).to be_truthy
      end

      it 'has a proper password message' do
        expect(form.error_object[:password])
          .to eq(I18n.t('password.errors.password_required'))
      end
    end
  end

  context 'when password confirmation is empty' do
    let(:confirmation) { '' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    describe 'error object' do
      before { form.valid? }

      it 'has a proper base message' do
        expect(form.error_object[:base_message])
          .to eq(I18n.t('password.errors.passwords_required'))
      end

      it 'has a display link set to true' do
        expect(form.error_object[:link]).to be_truthy
      end

      it 'has a proper password confirmation message' do
        expect(form.error_object[:password_confirmation])
          .to eq(I18n.t('password.errors.confirmation_required'))
      end
    end
  end

  context 'when password confirmation is different' do
    let(:confirmation) { 'other_password' }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    describe 'error object' do
      before { form.valid? }

      it 'has a proper base message' do
        expect(form.error_object[:base_message])
          .to eq(I18n.t('password.errors.password_equality'))
      end

      it 'has a display link set to true' do
        expect(form.error_object[:link]).to be_truthy
      end

      it 'has a proper password message' do
        expect(form.error_object[:password])
          .to eq(I18n.t('password.errors.password_equality'))
      end

      it 'has a proper password confirmation message' do
        expect(form.error_object[:password_confirmation])
          .to eq(I18n.t('password.errors.password_equality'))
      end
    end
  end

  context 'when password is same as old_password' do
    let(:old_password_hash) { Digest::MD5.hexdigest(password) }

    it 'is not valid' do
      expect(form).not_to be_valid
    end

    describe 'error object' do
      before { form.valid? }

      it 'has a proper base message' do
        expect(form.error_object[:base_message])
          .to eq(I18n.t('password.errors.password_unchanged'))
      end

      it 'has a display link set to false' do
        expect(form.error_object[:link]).to be_falsey
      end

      it 'has no password message' do
        expect(form.error_object[:password]).to be_nil
      end

      it 'has no confirmation message' do
        expect(form.error_object[:password_confirmation]).to be_nil
      end
    end
  end
end
