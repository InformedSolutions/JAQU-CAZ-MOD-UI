# frozen_string_literal: true

# Scenario: View upload page without cookie
When('I have no authentication cookie') do
  cookie = get_me_the_cookie('_csv_uploader_session')
  expect(cookie).to be_nil
end

# Scenario: View upload page with cookie that has not expired
When('I navigate to a Upload page') do
  visit upload_index_path
end

Then('I am redirected to the Sign in page') do
  expect(page).to have_current_path(user_session_path)
end

Then('I should enter valid credentials and press the Continue') do
  sign_in_user
end

And('Cookie is created for my session') do
  cookie = get_me_the_cookie('_csv_uploader_session')
  expect(cookie).to_not be_nil
end

# Scenario: View upload page with cookie that has not expired
When('I have authentication cookie that has not expired') do
  visit new_user_session_path
  sign_in_user

  cookie = get_me_the_cookie('_csv_uploader_session')
  expect(cookie).to_not be_nil
  expect(cookie[:expires] > Time.current).to be true
end

Then('I am redirected to the Upload page') do
  expect(page).to have_current_path(upload_index_path)
end

# Scenario: Sign in with invalid credentials
When('I enter invalid credentials') do
  fill_in('user_username', with: 'user@example.com')
  fill_in('user_password', with: 'invalid-password')

  allow(Cognito::AuthUser).to receive(:call).and_raise(
    Aws::CognitoIdentityProvider::Errors::InvalidPasswordException.new('', '')
  )

  click_button 'Continue'
end

Then('I remain on the current page') do
  expect(page).to have_current_path(new_user_session_path)
end

# Scenario: View upload page with cookie that has expired
Given('I have authentication cookie that has expired') do
  # set default session_timeout
  Rails.configuration.x.session_timeout = 15

  travel_to(20.minutes.ago) do
    sign_in_user
  end

  cookie = get_me_the_cookie('_csv_uploader_session')
  expect(cookie).to_not be_nil
  expect(cookie[:expires] < Time.current).to be true
end

# Scenario: Sign out
Given('I am signed in') do
  sign_in_user
end

When('I request to sign out') do
  click_link 'Sign Out'
end

# Scenario: Sign in with invalid email format
When('I enter invalid email format') do
  fill_in('user_username', with: 'user.example.com')
  fill_in('user_password', with: '12345678')

  click_button 'Continue'
end

# Scenario: Sign in with too long email address
When('I enter too long email address') do
  fill_in('user_username', with: "#{SecureRandom.alphanumeric(36)}@email.com")
  fill_in('user_password', with: '12345678')

  click_button 'Continue'
end
