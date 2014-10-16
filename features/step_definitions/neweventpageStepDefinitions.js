var myStepDefinitionsWrapper = function () {
  //this.World = require("../support/world.js").World; // overwrite default World constructor
  var Given = When = Then = this.defineStep;
  var zombie = require('zombie');
  var assert = require('assert');
  var browser = new zombie();

  When(/^I click on "([^"]*)" menu$/, function (menuName, callback) {
    // Write code here that turns the phrase above into concrete actions

    switch (menuName) {
      case "NEW EVENT TEMPLATE":
        href = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/new_template\"]";
        break;
      case "SHOW ARCHIVE":
        href = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/show_archive\"]";
        break;
      case "SHOW EVENT TEMPLATES":
        href = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/\"]";
        break;
    }

    this.clickMenu(href ,callback);
  });

};

module.exports = myStepDefinitionsWrapper;
