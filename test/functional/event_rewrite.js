process.env.NODE_ENV = 'test';

// use zombie.js as headless browser
var Browser = require('zombie');
// load Node.js assertion module
var assert = require('assert');

describe ('Events Rewrite', function() {

  //describe home page

  before(function() {
    // initialize the browser using the same port as the test application
    this.browser = new Browser({ site: 'http://eventmgr.dev' });
  });

  // load the home page
  before(function(done) {
    this.browser.visit('/', done);
  });

  describe('Home page', function() {

    it('should show a list of event templates', function() {
       assert.ok(this.browser.success);
       assert.equal(this.browser.text('h1'), 'Boots Coaching Capability 1Boots Coaching Capability 2Boots Coaching Capability 3Boots Coaching Capability 4Boots Coaching Capability 5Boots Coaching Capability 6Boots Coaching Capability 7Boots Coaching Capability 8Boots Coaching Capability 9Boots Coaching Capability 10');
    });

    it('should have an id, search', function() {

      assert.equal(this.browser.text('#search'), 'A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z |');
    });

    it('should contain Show Archive button', function() {

      assert(this.browser.query('input[value="Show Archive"]'), 'has Show Archive button');
    });

  });

  // describe new event template
  describe('New event template', function() {

    it('should open a new event template form', function(done) {
       var browser = this.browser;
       button = browser.query('a[href="/new_template"]');
       //console.log(button.href)
       browser.pressButton(button).then(function() {
         assert.ok(browser.success);
         assert.equal(browser.text('h1'), 'Create New Event Template');
         assert.equal(browser.location.pathname, '/new_template')
       }).then(done, done);

    });
    it('should create a new event template', function(done) {
       //var browser = this.browser;
       this.browser.
       fill('title', 'Boots Coaching Capability 11').
       fill('duration', '08:40').
       fill('amount0', '10').
       fill('amount1', '20').
       fill('amount2', '30').
       fill('amount3', '40').
       fill('amount4', '50').
       fill('description', 'New Event template description').
       pressButton('Create Template', function(error) {
         if (error) return done(error);
         assert.ok(browser.success);
         assert.equal(browser.location.pathname, '/')
         assert.equal(browser.text('h1'), 'Boots Coaching Capability 1Boots Coaching Capability 2Boots Coaching Capability 3Boots Coaching Capability 4Boots Coaching Capability 5Boots Coaching Capability 6Boots Coaching Capability 7Boots Coaching Capability 8Boots Coaching Capability 9Boots Coaching Capability 10Boots Coaching Capability 11');
         done();
       });

    });

  });

  after(function(done) {
    this.browser.visit('/reset', done);
  });


});
