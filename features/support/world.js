// features/support/world.js
module.exports = function() {
  var zombie = require('zombie');
  var assert = require('assert');


  this.Before(function(callback) {
    var browser = new zombie();
    browser.visit('http://eventsmgr.dev', function() {
      assert.ok(browser.success);
      assert.equal(browser.statusCode, "200");
      assert.equal(browser.location.pathname, "/");
      callback();
    });
  });

  this.After(function(callback) {
    var browser = new zombie();
    browser.visit('http://eventsmgr.dev/reset', function() {
      assert.ok(browser.success);
      assert.equal(browser.statusCode, "200");
      callback();
    });
  });

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

    this.isListOfTemplates = function(callback) {
      assert.ok(browser.query("a[data-toggle = \"collapse\"]"));
      assert.ok(browser.query("a[data-parent=\"#accordion\"]"));
      callback();
    };

    this.clickMenu = function(selector, callback) {

      var button = browser.query(selector);
      var url = button.href;

      browser.visit(url, function() {
        assert.ok(browser.success);
        assert.equal(browser.statusCode, "200");
        pathname = url.split('http://eventsmgr.dev')[1];
        assert.equal(browser.location.pathname, pathname);
        callback();
      });
    };

    this.fillIn = function(field, value, callback) {
      browser.fill(field, value);
      callback();
    };

    this.clickButton = function(name, callback) {
      browser.pressButton(name, function() {
        assert.ok(browser.success);
        assert.equal(browser.statusCode, "200");
        callback();
      });
    };

    this.checkTemplate = function(name, callback) {

      assert.equal(browser.text("a[data-toggle = \"collapse\"]:last"), name);

      // assert.equal(browser.query("a[data-toggle = \"collapse\"]:last") == "Boots");
      callback();

    };


    callback(); // tell Cucumber we're finished and to use 'this' as the world instance
  };
}
