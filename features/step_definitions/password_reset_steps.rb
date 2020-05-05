# frozen_string_literal: true

def username
  'wojtek@example.com'
end

Given('I am on the forgotten password page') do
  visit reset_passwords_path
end

When('I enter my username') do
  allow(Cognito::ForgotPassword::Reset)
    .to receive(:call)
    .with(username: username)
    .and_return(true)
  fill_in('user[username]', with: username)
  click_button 'Reset password'
end

Then("I am taken to the 'Reset link sent' page") do
  expect(page.current_url).to eq(confirm_reset_passwords_url)
end

Given("I am on the 'Reset link sent' page") do
  allow(Cognito::ForgotPassword::Reset).to receive(:call).and_return(true)
  allow(Cognito::ForgotPassword::UpdateUser).to receive(:call).and_return(true)
  visit reset_passwords_path
  fill_in('user[username]', with: username)
  click_button 'Reset password'
  # expect proper page
  expect(page).to have_current_path(confirm_reset_passwords_path)
end

When('I enter valid code and passwords') do
  password = 'password'
  code = '123456'
  allow(Cognito::ForgotPassword::Confirm)
    .to receive(:call).with(
      username: username,
      password: password,
      code: code,
      password_confirmation: password
    ).and_return(true)
  fill_in('user[confirmation_code]', with: code)
  fill_in('user[password]', with: password)
  fill_in('user[password_confirmation]', with: password)
  click_button 'Update password'
end

When('I enter invalid email') do
  fill_in('user[username]', with: 'wojtek')
  click_button 'Reset password'
end

Then('I remain on the update password page') do
  expect(page).to have_current_path(reset_passwords_path)
end

And('I enter only confirmation code') do
  code = '123456'

  fill_in('user[confirmation_code]', with: code)
  click_button 'Update password'
end
