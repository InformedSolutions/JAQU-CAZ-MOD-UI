# frozen_string_literal: true

require 'rails_helper'

describe Cognito::AuthUser do
  subject { described_class.call(username: username, password: password, login_ip: remote_ip) }

  let(:username) { 'wojtek@example.com' }
  let(:password) { 'password' }
  let(:remote_ip) { '1.2.3.4' }

  context 'with successful call' do
    before do
      allow(Cognito::Client.instance).to receive(:initiate_auth).with(
        client_id: anything,
        auth_flow: 'USER_PASSWORD_AUTH',
        auth_parameters:
            {
              'USERNAME' => username,
              'PASSWORD' => password
            }
      ).and_return(auth_response)
    end

    context 'when user changed the password' do
      let(:auth_response) { OpenStruct.new(authentication_result: OpenStruct.new(access_token: token)) }
      let(:token) { SecureRandom.uuid }

      before {  allow(Cognito::GetUser).to receive(:call).with(access_token: token).and_return(User.new) }

      it 'calls Cognito::GetUser' do
        expect(Cognito::GetUser)
          .to receive(:call)
          .with(access_token: token, username: username, user: an_instance_of(User))
        subject
      end
    end

    context 'when user did not change the password' do
      let(:email) { 'test@example.com' }
      let(:session_key) { SecureRandom.uuid }
      let(:auth_response) do
        OpenStruct.new(challenge_parameters: {
                         'USER_ID_FOR_SRP' => username,
                         'userAttributes' => { 'email' => email }.to_json
                       }, session: session_key)
      end

      it 'returns an instance of the user class' do
        expect(subject).to be_a(User)
      end

      it 'sets user email' do
        expect(subject.email).to eq(email)
      end

      it 'sets username' do
        expect(subject.username).to eq(username)
      end

      it 'sets aws_status to FORCE_NEW_PASSWORD' do
        expect(subject.aws_status).to eq('FORCE_NEW_PASSWORD')
      end

      it 'sets aws_session' do
        expect(subject.aws_session).to eq(session_key)
      end

      it 'sets hashed password' do
        expect(subject.hashed_password).to eq(Digest::MD5.hexdigest(password))
      end

      it 'sets login_ip' do
        expect(subject.login_ip).to eq(remote_ip)
      end
    end
  end

  context 'when call raises `NotAuthorizedException` exception' do
    before do
      allow(Cognito::Client.instance)
        .to receive(:initiate_auth)
        .and_raise(
          Aws::CognitoIdentityProvider::Errors::NotAuthorizedException.new('', 'error')
        )
    end

    it 'returns false' do
      expect(subject).to be_falsey
    end
  end

  context 'when call raises `ServiceError` exception' do
    before do
      allow(Cognito::Client.instance).to receive(:initiate_auth).and_raise(
        Aws::CognitoIdentityProvider::Errors::ServiceError.new('', 'error')
      )
    end

    it 'returns false' do
      expect(subject).to be_falsey
    end
  end
end
