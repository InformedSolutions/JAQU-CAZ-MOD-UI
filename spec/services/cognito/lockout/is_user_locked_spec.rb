# frozen_string_literal: true

require 'rails_helper'

describe Cognito::Lockout::IsUserLocked do
  subject { described_class.call(username: username) }

  let(:username) { 'user@example.com' }
  let(:locked) { false }
  let(:unlockable) { false }

  before do
    user_data_stub = instance_double(
      Cognito::Lockout::UserData,
      locked?: locked,
      unlockable?: unlockable
    )
    allow(Cognito::Lockout::UserData).to receive(:new).and_return(user_data_stub)
  end

  context 'when user is not locked' do
    it 'returns false' do
      expect(subject).to eq(false)
    end
  end

  context 'when user is locked' do
    let(:locked) { true }

    it 'returns true' do
      expect(subject).to eq(true)
    end
  end
end
