Feature: Static Pages
	In order to ensure consistency across static pages
	As a guest
	I want to visit static pages and verify layout

	Scenario: Home Page
		Given I am a guest
		When I go to homepage
		Then title is default title.

