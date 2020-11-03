# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::Lockout::AttemptUserUnlock do
  subject { described_class.call(username: username) }

  let(:username) { 'user@example.com' }
  let(:unlockable) { true }

  before do
    user_data_stub = instance_double('Cognito::Lockout::UserData', unlockable?: unlockable)
    allow(Cognito::Lockout::UserData).to receive(:new).and_return(user_data_stub)
    allow(Cognito::Lockout::UpdateUser).to receive(:call)
      .with(username: username, failed_logins: 0, lockout_time: nil)

    subject
  end

  context 'when user is unlockable' do
    it 'unlocks user' do
      expect(Cognito::Lockout::UpdateUser).to have_received(:call)
        .with(username: username, failed_logins: 0, lockout_time: nil)
    end
  end

  context 'when user is not unlockable' do
    let(:unlockable) { false }

    it 'does not unlock user' do
      expect(Cognito::Lockout::UpdateUser).not_to have_received(:call)
    end
  end
end
