// features/support/world.js
module.exports = function() {
  var zombie = require('zombie');
  var assert = require('assert');

  this.World = function World(callback) {
    var browser = new zombie(); // this.browser will be available in step definitions

    this.visitHome = function(url, callback) {
      //var browser = this.browser;
      browser.visit(url, function() {
        assert.ok(browser.success);
        //assert.equal(browser.text('h1'), 'Boots Coaching Capability 1Boots Coaching Capability 2Boots Coaching Capability 3Boots Coaching Capability 4Boots Coaching Capability 5Boots Coaching Capability 6Boots Coaching Capability 7Boots Coaching Capability 8Boots Coaching Capability 9Boots Coaching Capability 10');
        callback();

      });

    };

    callback(); // tell Cucumber we're finished and to use 'this' as the world instance
  };
}
