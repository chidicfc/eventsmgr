var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  Given(/^I am on the events system home page$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    this.visitHome ('http://eventsmgr.dev', callback);
  });

  Then(/^I should see "([^"]*)" header$/, function (str, callback) {
    // Write code here that turns the phrase above into concrete actions
    this.checkHeader(str, callback);
  });

  Then(/^I should see a list of event templates$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    this.isListOfTemplates(callback);
  });

};

module.exports = myStepDefinitionsWrapper;
