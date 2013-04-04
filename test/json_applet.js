
var _     = require('underscore')
, assert  = require('assert')
, Applet  = require('json_applet').Applet
, cheerio = require('cheerio');
;

var HTML = {
  'block' : function (args, meta) {
    return "<div>" + err_check(meta.app.run(args)).join("") + "</div>";
  },
  'parent form': function (args, meta) {
    return "<form>" + err_check(meta.app.run(args)).join("") + "</form>";
  },
  'form . text_input' : function (args, meta) {
    return '<input>' + args[0] + '</input>';
  }
};

var Ok      = function (source) { return Applet(source, HTML).run(); };
var ERROR   = function (source) { return Ok(source).error; };
var RESULTS = function (source) {
  var results = Ok(source);
  if (results.error)
    throw error;
  return results.results;
};

var err_check = function (results) {
  if (results && results.error)
    return [results.error.message];
  return results.results;
};


describe( 'Applet', function () {

  describe( '.run', function () {

    it( 'returns error if func not defined', function () {
      var html = [
        'text_boxs', ['my name', "something else"]
      ];

      assert.equal(ERROR(html).message, "Func not found: text_boxs");
    });

  }); // === end desc

  describe( 'in parent', function () {

    it( 'returns error if child element is used as a parent', function () {
      var html = [
        'text_input', ['my name', "something else"]
      ];
      assert.equal(ERROR(html).message, "text_input: can only be used within \"form\".");
    });

  }); // === end desc

  describe( 'parent ', function () {

    it( 'runs funcs defined for parent', function () {
      var slang = [
        'form', [
          'text_input', [ "hello world" ]
        ]
      ];
      assert.equal(RESULTS(slang).join(""), '<form><input>hello world</input></form>');
    });

    it( 'returns error if parent element is used as a child within another parent: form > form', function () {
      var html = [
        'form', [ 'form', [ 'text_input', ['my_name', 'some text']] ]
      ];
      assert.equal(ERROR(html).message, "form: can not be used within another \"form\".");
    });

    it( 'returns error if parent element is used as a nested child: form > block > form', function () {
      var html = [
        'form', [ 'block', [ 'form', ['my_name', 'some text']] ]
      ];
      assert.equal(ERROR(html).message, "form: can not be used within another \"form\".");
    });

  }); // === end desc

}); // === end desc


