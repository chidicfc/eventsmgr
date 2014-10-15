process.env.NODE_ENV = 'test';

// use zombie.js as headless browser
var Browser = require('zombie');
// load Node.js assertion module
var assert = require('assert');
