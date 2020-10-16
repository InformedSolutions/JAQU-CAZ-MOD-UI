# frozen_string_literal: true

When('I sign in on the locked out account') do
  allow(Cognito::Lockout::IsUserLocked).to receive(:call).and_return(true)
  visit new_user_session_path
  basic_sign_in
end
