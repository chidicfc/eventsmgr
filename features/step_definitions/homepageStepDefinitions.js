var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;

  Given(/^I am on the events system home page$/, function (callback) {
    // Write code here that turns the phrase above into concrete actions
    this.visitHome ('http://eventsmgr.dev', callback);
  });

};

module.exports = myStepDefinitionsWrapper;
