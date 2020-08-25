# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::Lockout::UserData do
  subject { described_class.new(username: username) }

  let(:username) { 'user@example.com' }
  let(:user_response) do
    OpenStruct.new(
      user_attributes: [
        OpenStruct.new(name: 'custom:failed-logins', value: failed_logins),
        OpenStruct.new(name: 'custom:lockout-time', value: lockout_time)
      ]
    )
  end

  let(:failed_logins) { '0' }
  let(:lockout_time) { nil }

  before do
    allow(Cognito::Client.instance).to receive(:admin_get_user).with(
      user_pool_id: anything,
      username: username
    ).and_return(user_response)
  end

  describe '.invalid_logins' do
    context 'when failed-logins is nil' do
      let(:failed_logins) { nil }

      it 'returns 0' do
        expect(subject.invalid_logins).to eq 0
      end
    end

    context 'when failed-logins is not nil' do
      let(:failed_logins) { 3 }

      it 'returns the actual value' do
        expect(subject.invalid_logins).to eq(failed_logins)
      end
    end
  end

  describe '.lockout_time' do
    context 'when lockout-time is nil' do
      let(:lockout_time) { nil }

      it 'returns nil' do
        expect(subject.lockout_time).to eq(nil)
      end
    end

    context 'when lockout-time is not nil' do
      let(:lockout_time) { 10.minutes.ago.iso8601 }

      it 'returns parsed TimeWithZone object' do
        expect(subject.lockout_time).to be_a(ActiveSupport::TimeWithZone)
      end
    end
  end

  describe '.unlockable?' do
    context 'when user is not locked out' do
      let(:lockout_time) { nil }

      it 'returns false' do
        expect(subject.unlockable?).to eq(false)
      end
    end

    context 'when user is locked out and lockout timeout did not exceed' do
      let(:lockout_time) { Time.zone.now.iso8601 }

      it 'returns false' do
        expect(subject.unlockable?).to eq(false)
      end
    end

    context 'when user is locked out and lockout timeout exceeded' do
      let(:lockout_time) { 31.minutes.ago.iso8601 }

      it 'returns true' do
        expect(subject.unlockable?).to eq(true)
      end
    end
  end

  describe '.locked?' do
    context 'when lockout-time is nil' do
      let(:lockout_time) { nil }

      it 'returns false' do
        expect(subject.locked?).to eq(false)
      end
    end

    context 'when lockout-time is not nil' do
      let(:lockout_time) { 10.minutes.ago.iso8601 }

      it 'returns true' do
        expect(subject.locked?).to eq(true)
      end
    end
  end
end
