var myStepDefinitionsWrapper1 = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I click on NEW EVENT TEMPLATE$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    this.clickLink("div[class = \"col-md-6\"]:nth-child(2) a[href = \"/new_template\"]", callback);
  });

};

module.exports = myStepDefinitionsWrapper1;
