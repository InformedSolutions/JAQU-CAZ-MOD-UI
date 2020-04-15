# frozen_string_literal: true

module LoginHelpers
  def sign_in_user
    allow(Cognito::AuthUser).to receive(:call).and_return(unchallenged_cognito_user)
    visit new_user_session_path
    basic_sign_in
  end

  def sign_in_challenged_user
    allow(Cognito::AuthUser).to receive(:call).and_return(challenged_cognito_user)
    visit new_user_session_path
    basic_sign_in
  end

  def basic_sign_in
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:remote_ip)
      .and_return(remote_ip)
    fill_in('user_username', with: 'user@example.com')
    fill_in('user_password', with: '12345678')
    click_button 'Continue'
  end

  def unchallenged_cognito_user
    user = cognito_user
    user.aws_status = 'OK'
    user.aws_session = nil
    user
  end

  def challenged_cognito_user
    user = cognito_user
    user.aws_status = 'FORCE_NEW_PASSWORD'
    user.aws_session = SecureRandom.uuid
    user
  end

  def cognito_user
    User.new.tap do |u|
      u.username = 'user'
      u.email = 'user@example.com'
      u.login_ip = remote_ip
      u.authorized_list_type = 'green'
    end
  end

  def remote_ip
    '1.2.3.4'
  end
end

World(LoginHelpers)
