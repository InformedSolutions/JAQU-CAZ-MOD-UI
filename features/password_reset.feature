Feature: Password reset
  As a Licensing Authority
  I want to be able to reset my password
  So that I may still upload to the Ministry of Defence Data Portal, even if I forget my password

  Scenario: Go to forgotten password page
    Given I am on the Sign in page
    When I press "Forgot your password?" link
    Then I should see "Enter your email to reset password"

  Scenario: Go to update password page
    Given I am on the forgotten password page
    When I enter my username
    Then I am taken to the 'Reset link sent' page

  Scenario: Filling update password form
    Given I am on the 'Reset link sent' page
    When I enter valid code and passwords
    Then I am taken to Password set successfully page

  Scenario: Filling invalid email format
    Given I am on the forgotten password page
    When I enter invalid email
    Then I remain on the update password page
      And I should see "Enter your email address in a valid format"

  Scenario: Filling only confirmation code
    Given I am on the forgotten password page
      And I should see "Enter your email to reset password"
    When I enter my username
      And I should see "Update your password"
    Then I enter only confirmation code
      And I should see "Enter your password"

  Scenario: Filling invalid passwords
    Given I am on the 'Reset link sent' page
    When I enter passwords that does not comply with Cognito setup password policy
      And I press 'Update password' button
      And I should see 'Password must be at least 12 characters long, include at least one upper case letter, a number, and a special character' 3 times
