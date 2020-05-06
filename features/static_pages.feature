Feature: Cookies
  In order to read the page
  As a Licensing Authority
  I want to see cookies page

  Scenario: User sees cookies page
    Given I am on the Sign in page
    When I press 'Cookies' footer link
    Then I should see 'Cookies'

  Scenario: User sees accessibility statement page
    Given I am on the Sign in page
    When I press 'Accessibility statement' footer link
    Then I should see "Accessibility statement for Ministry of Defence Vehicle Data Portal"
