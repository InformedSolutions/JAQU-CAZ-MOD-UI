# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cognito::GetUser do
  subject(:service_call) { described_class.call(access_token: token, username: username) }

  let(:token) { SecureRandom.uuid }
  let(:cognito_response) do
    OpenStruct.new(username: username, user_attributes: [
                     OpenStruct.new(name: 'email', value: email),
                     OpenStruct.new(name: 'sub', value: sub),
                     OpenStruct.new(
                       name: 'custom:authorized-list-type',
                       value: authorized_list_type
                     )
                   ])
  end
  let(:email) { 'test@example.com' }
  let(:username) { 'wojtek' }
  let(:sub) { SecureRandom.uuid }
  let(:authorized_list_type) { 'green' }

  before do
    allow(COGNITO_CLIENT).to receive(:get_user)
      .with(access_token: token)
      .and_return(cognito_response)
  end

  it 'returns an instance of the user class' do
    expect(service_call).to be_a(User)
  end

  it 'sets user email' do
    expect(service_call.email).to eq(email)
  end

  it 'sets username' do
    expect(service_call.username).to eq(username)
  end

  it 'sets aws_status to OK' do
    expect(service_call.aws_status).to eq('OK')
  end

  it 'sets aws_session to nil' do
    expect(service_call.aws_session).to eq(nil)
  end

  it 'sets sub' do
    expect(service_call.sub).to eq(sub)
  end

  it 'sets authorized_list_type' do
    expect(service_call.authorized_list_type).to eq(authorized_list_type)
  end

  context 'when the initial user is given' do
    subject(:service_call) do
      described_class.call(access_token: token, username: username, user: user)
    end

    let(:user) { User.new(login_ip: remote_ip) }
    let(:remote_ip) { '1.2.3.4' }

    it 'does not override login_ip' do
      expect(service_call.login_ip).to eq(remote_ip)
    end
  end
end
