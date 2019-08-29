Feature: Password reset
  As a Licensing Authority
  I want to be able to reset my password
  So that I may still upload to the National Taxi register, even if I forget my password

  Scenario: Go to forgotten password page
    Given I am on the Sign in page
    When I press "Forgot your password?" link
    Then I should see "Enter your email to reset your password."

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
      And I should see "The email is in an invalid format"

  Scenario: Filling too long email address
    Given I am on the forgotten password page
    When I enter too long email
    Then I remain on the update password page
      And I should see "The email exceeds the limit of 45 characters"
