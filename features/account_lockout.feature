Feature: Lockout user account after limited amount of login attempts
  As a Licensing Authority
  I want to be uncapable of signing in after limited amount of login attempts
  So I am sure that my password won't be brutforced

  Scenario: Login with locked account
    Given I am on the Sign in page
      And I sign in on the locked out account
    Then I should see 'Enter a valid email address and password'
