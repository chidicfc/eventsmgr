Scenario: Can't Delete Template with events
  Given I am on the events system home page
  When I click on "ARCHIVE" submenu
  Then I should see "Boots Coaching Capability 1 (1, 08:30)" event template

##############

var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I click on "([^"]*)" submenu$/, function (subMenuName, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.clickSubMenu(subMenuName, callback);
  });

};

module.exports = myStepDefinitionsWrapper;
