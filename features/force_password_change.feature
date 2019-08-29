Feature: Force password change on first login
  As a Licensing Authority
  I want to be forced to change my password on first log in
  So I am sure password is secure and is unknown for anyone else

  Scenario: First login
    Given I am on the Sign in page
      And I am a newly created user
      And I enter valid credentials
    Then I am transferred to “Force Change password” page

  Scenario: Invalid new password
    Given I am on a Force Change password page
      And I enter password that does not comply with Cognito setup password policy
    Then I am presented with an error
      And I can retry

  Scenario: Valid new password
    Given I am on a Force Change password page
      And I enter password that is compliant with Cognito setup password policy
    Then I am taken to Password set successfully page
