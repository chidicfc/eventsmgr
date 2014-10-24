var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I click on "([^"]*)" menu$/, function (menuName, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.clickMenu(menuName ,callback);
  });

};

module.exports = myStepDefinitionsWrapper;
