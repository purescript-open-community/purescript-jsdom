"use strict";

const JSDOM = require('jsdom').JSDOM

exports._jsdom = function(html, constructorOptions) {
  return new JSDOM(html, constructorOptions)
};

exports._window = function(jsdom) {
  return jsdom.window
};

exports.document = function(jsdomWindow) {
  return function () {
    return jsdomWindow.document
  }
};
