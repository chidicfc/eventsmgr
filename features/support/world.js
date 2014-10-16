// features/support/world.js
module.exports = function() {
  var zombie = require('zombie');
  var assert = require('assert');

  this.World = function World(callback) {
    var browser = new zombie(); // this.browser will be available in step definitions

    this.visitHome = function(url, callback) {
      browser.visit(url, function() {
        assert.ok(browser.success);
        assert.equal(browser.statusCode, "200");
        assert.equal(browser.location.pathname, "/");
        callback();
      });
    };

    this.checkHeader = function (str, callback) {
      assert.equal(browser.text("h3"), str);
      callback();
    };

    callback(); // tell Cucumber we're finished and to use 'this' as the world instance
  };
}
