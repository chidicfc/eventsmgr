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

    this.clickMenu = function(menuName, callback) {

      switch (menuName) {
        case "NEW EVENT TEMPLATE":
          selector = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/new_template\"]";
          break;
        case "SHOW ARCHIVE":
          selector = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/show_archive\"]";
          break;
        case "SHOW EVENT TEMPLATES":
          selector = "div[class = \"col-md-6\"]:nth-child(2) a[href = \"/\"]";
          break;
      }

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
      switch(name) {

        case "Boots (0, 0:0)":
          assert.equal(browser.text("a[data-toggle = \"collapse\"]:last"), name);
          break;
        default:
          assert.equal(browser.text("a[data-toggle = \"collapse\"]:first"), name);
      }
      callback();
    };

    this.clickSubMenu = function(subMenuName, callback) {

      switch (subMenuName) {
        case "CREATE NEW EVENT":
          selector = "div[class = \"panel panel-default\"]:nth-child(1) a[href = \"/1/new_event?action=new\"]";
          break;
        case "EDIT":
          selector = "div[class = \"panel panel-default\"]:nth-child(1) a[href = \"/event_template/1/edit\"]";
          break;
        // case "DELETE":
        //   selector = "div[class = \"panel panel-default\"]:nth-child(1) a[class = \"btn btn-danger btn-xs pull-right deleteEventTemp\"] span[onclick=\"$(this).parent().submit()\"]";
        //   break;
        // case "ARCHIVE":
        //   selector = "div[class = \"panel panel-default\"]:nth-child(1) a[class = \"btn btn-primary btn-xs pull-right\"] span[onclick=\"$(this).parent().submit()\"]";
        //   break;
      }


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


    callback(); // tell Cucumber we're finished and to use 'this' as the world instance
  };
}
