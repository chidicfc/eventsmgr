// use zombie.js as headless browser
var Browser = require('zombie');
// load Node.js assertion module
var assert = require('assert');



describe('Event Rewrite', function() {


  //describe home page
  before(function() {
    // initialize the browser using the same port as the test application
    this.browser = new Browser({ site: 'http://eventsmgr.dev' });
    this.timeout(15000);
  });

  // load the home page
  before(function(done) {
    this.browser.visit('/', done);

  });

  describe('Home page', function() {
    it('should show a list of event templates', function() {

    });

  });

  after(function(done) {
    this.browser.visit('/reset', done);

  });

});
