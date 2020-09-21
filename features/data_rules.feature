Feature: Data Rules
  In order to read the page
  As a Licensing Authority
  I want to be able to visit a guidance page on data submissions

  Scenario: See Data rules
    Given I am on the Upload page
    When I press Data rules button
    Then I should see "Ministry of Defence Data Portal" 2 times
