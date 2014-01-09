Feature: Google
  In order to verify search capabilities
  As a guest
  I want to visit google

  Scenario: Proper Google Title
    Given I am a guest
    When I visit http://www.google.com
    Then "Settings" is visible

