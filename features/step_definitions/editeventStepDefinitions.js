var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I click on "([^"]*)" sub\-menu$/, function (subMenuName, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.clickSubMenu(subMenuName ,callback);
  });

};

module.exports = myStepDefinitionsWrapper;
