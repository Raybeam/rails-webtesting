Feature: Static Pages
	In order to ensure consistency across static pages
	As a guest
	I want to visit static pages and verify layout

	Scenario: Proper Home Page Title
		Given I am a guest
		When I go to homepage
		Then title is default title.

    Scenario: Link to Signup from Home Page
      Given I am a guest
      When I go to homepage
      And click on link to sign up
      Then "Sign up" is visible

