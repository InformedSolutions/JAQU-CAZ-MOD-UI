# frozen_string_literal: true

Then('I should see {string}') do |string|
  expect(page).to have_content(string)
end

Then('I should see {string} {int} times') do |string, count|
  expect(page).to have_content(string, count: count.to_i)
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

Then('I am redirected to the root page') do
  expect(page).to have_current_path('/')
end

Then('I should see {string} link') do |string|
  expect(page).to have_link(string)
end

Then('I am redirected to the Upload page') do
  expect(page).to have_current_path(authenticated_root_path)
end

Then('I should not see {string} link') do |string|
  expect(page).not_to have_link(string)
end

When('I refresh the page') do
  visit page.current_path
end
