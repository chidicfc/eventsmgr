Feature: Events Rewrite
  As a user of the events system
  I want to be able to perform several events-related actions
  So that I can create event templates, events etc

  Scenario: Home page
    Given I am on the events system home page
    Then I should see "Event Templates" header
    And I should see a list of event templates

  Scenario: Create Event Templates
    Given I am on the events system home page
    When I click on NEW EVENT TEMPLATE
    Then I should see "Create New Event Template" header
