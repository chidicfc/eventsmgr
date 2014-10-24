Feature: Events Rewrite
  As a user of the events system
  I want to be able to perform several events-related actions
  So that I can create event templates, events etc

  Scenario: Home page
    Given I am on the events system home page
    Then I should see "Event Templates" header
     And I should see a list of event templates

  Scenario: Can Open New Event Templates Form
    Given I am on the events system home page
    When I click on "NEW EVENT TEMPLATE" menu
    Then I should see "Create New Event Template" header

  Scenario: Create New Event Template
    Given I am on the events system home page
    When I click on "NEW EVENT TEMPLATE" menu
      And I fill in "title" with "Boots"
      And I click on "Create Template" submit button
    Then I should see "Event Templates" header
      And I should see "Boots (0, 0:0)" event template

  Scenario: Can Open Edit Event Template Form
    Given I am on the events system home page
    When I click on "EDIT" sub-menu
    Then I should see "Edit Boots Coaching Capability 1" header

  Scenario: Edit Event Template
    Given I am on the events system home page
    When I click on "EDIT" sub-menu
      And I fill in "title" with "Asda"
      And I click on "Edit Template" submit button
    Then I should see "Asda (1, 0:0)" event template
