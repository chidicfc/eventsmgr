Feature: Events Rewrite
  As a user of the events system
  I want to be able to perform several events-related actions
  So that I can create event templates, events etc

  Scenario: Home page
    Given I am on the events system home page
    Then I should see "Event Templates" header
     And I should see a list of event templates

  Scenario: New Event Templates Form
    Given I am on the events system home page
    When I click on "NEW EVENT TEMPLATE" menu
    Then I should see "Create New Event Template" header

  Scenario: Create New Event Template
    Given I am on the events system home page
    When I click on "NEW EVENT TEMPLATE" menu
      And I fill in "Title" with "Boots"
      And I click on "CREATE TEMPLATE" submit button
    Then I should see "Event Templates" header
      And I should see "Title" event template
