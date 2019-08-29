# frozen_string_literal: true

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
  user = User.new
  user.username = 'user'
  user.email = 'user@example.com'
  user
end

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should see {string} title') do |string|
  expect(page).to have_title(string)
end

Then('I press the Continue') do
  click_button 'Continue'
end

Then('I press {string} button') do |string|
  click_button string
end

Then('I press {string} link') do |string|
  click_link string
end

Given('I am on the Upload page') do
  sign_in_user
  visit root_path
end

Given('I am on the Sign in page') do
  visit new_user_session_path
end

Then('I should see {string} link') do |string|
  expect(page).to have_link(string)
end

Then('I should not see {string} link') do |string|
  expect(page).not_to have_link(string)
end
