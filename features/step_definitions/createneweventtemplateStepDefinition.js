var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I fill in "([^"]*)" with "([^"]*)"$/, function (field, value, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.fillIn(field, value, callback);
  });

  When(/^I click on "([^"]*)" submit button$/, function (buttonName, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.clickButton(buttonName, callback);
  });

};

module.exports = myStepDefinitionsWrapper;
