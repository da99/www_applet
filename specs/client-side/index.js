
"use strict";

/* global QUnit */
/* global WWW_Applet */
/* global _ */
/* global expect */
/*jshint multistr:true */

// ==================================================================
QUnit.module("WWW_Applet");
// ==================================================================

QUnit.test( "it runs the code", function ( assert ) {
  WWW_Applet.run([
    "focus on", ['#box_1'],
    "add class", ['weird']
  ]);
  assert.ok( $('#box_1').hasClass('weird') === true, "Passed!" );
});


QUnit.test( "it evals the args as code", function( assert ) {
  var o = WWW_Applet.run([
    "add to stack", ["array", [1,2,3]]
  ]);
  assert.deepEqual( o.stack, [[1,2,3]], "Args are eval'd before run." );
});


QUnit.test("throws error if not enough stack values", function (assert) {
  assert.throws(function () {
    WWW_Applet.run(['less or equal', [5]]);
  }, /Not enough in stack values/);
});


QUnit.test("throws error if not enough arg values", function (assert) {
  assert.throws(function () {
    WWW_Applet.run(['less or equal', []]);
  }, /Not enough in args/);
});


// ==================================================================
QUnit.module("less or equal");
// ==================================================================

QUnit.test('it places true if: 5 <= 6', function (assert) {
  var o = WWW_Applet.run([
    5, "less or equal", [ 6 ]
  ]);
  assert.equal( _.last(o.stack), true);
});

QUnit.test('it places true if: 6 <= 6', function (assert) {
  var o = WWW_Applet.run([
    6, "less or equal", [ 6 ]
  ]);
  assert.equal( _.last(o.stack), true);
});

QUnit.test('it places false if: 7 <= 6', function (assert) {
  var o = WWW_Applet.run([
    7, "less or equal", [ 6 ]
  ]);
  assert.equal( _.last(o.stack), false);
});

QUnit.test('throws error if first num is not a number', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      '5', 'less or equal', [5] 
    ]);
  }, /Stack value is not a Number: String: 5/);
});

QUnit.test('throws error if second num is not a number', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      5, 'less or equal', ["6"] 
    ]);
  }, /Arg is not a Number: String: 6/);
});


// ==================================================================
QUnit.module("bigger or equal");
// ==================================================================

QUnit.test('it places true if: 6 >= 4', function (assert) {
  var o = WWW_Applet.run([
    6, "bigger or equal", [ 4 ]
  ]);
  assert.equal( _.last(o.stack), true);
});

QUnit.test('it places true if: 6 >= 6', function (assert) {
  var o = WWW_Applet.run([
    6, "bigger or equal", [ 6 ]
  ]);
  assert.equal( _.last(o.stack), true);
});

QUnit.test('it places false if: 6 >= 7', function (assert) {
  var o = WWW_Applet.run([
    6, "bigger or equal", [ 7 ]
  ]);
  assert.equal( _.last(o.stack), false);
});

QUnit.test('throws error if first num is not a number', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      '3', 'bigger or equal', [5] 
    ]);
  }, /Stack value is not a Number: String: 3/);
});

QUnit.test('throws error if second num is not a number', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      5, 'bigger or equal', ["9"] 
    ]);
  }, /Arg is not a Number: String: 9/);
});


// ==================================================================
QUnit.module('bigger');
// ==================================================================

QUnit.test('it places true on stack if: 6 > 1', function (assert) {
  var o = WWW_Applet.run([
    6, 'bigger', [1]
  ]);
  assert.equal(_.last(o.stack), true);
});


QUnit.test('it places false on stack if: 6 > 6', function (assert) {
  var o = WWW_Applet.run([
    6, 'bigger', [6]
  ]);
  assert.equal(_.last(o.stack), false);
});


// ==================================================================
QUnit.module('less');
// ==================================================================

QUnit.test('it places true on stack if: 1 < 6', function (assert) {
  var o = WWW_Applet.run([
    1, 'less', [6]
  ]);
  assert.equal(_.last(o.stack), true);
});


QUnit.test('it places false on stack if: 6 < 6', function (assert) {
  var o = WWW_Applet.run([
    6, 'less', [6]
  ]);
  assert.equal(_.last(o.stack), false);
});

QUnit.test('it places false on stack if: 6 < 1', function (assert) {
  var o = WWW_Applet.run([
    6, 'less', [1]
  ]);
  assert.equal(_.last(o.stack), false);
});


// ==================================================================
QUnit.module('equal');
// ==================================================================

QUnit.test('it places true on stack if: 1 === 1', function (assert) {
  var o = WWW_Applet.run([
    1, 'equal', [1]
  ]);
  assert.equal(_.last(o.stack), true);
});

QUnit.test('it places true on stack if: \'a\' === \'a\'', function (assert) {
  var o = WWW_Applet.run([
    "a", 'equal', ["a"]
  ]);
  assert.equal(_.last(o.stack), true);
});

QUnit.test('it places false on stack if: \'5\' === 5', function (assert) {
  var o = WWW_Applet.run([
    "5", 'equal', [5]
  ]);
  assert.equal(_.last(o.stack), false);
});


QUnit.test('it places false on stack if: 6 === \'6\'', function (assert) {
  var o = WWW_Applet.run([
    6, 'equal', ["6"]
  ]);
  assert.equal(_.last(o.stack), false);
});


// ==================================================================
QUnit.module('and');
// ==================================================================

QUnit.test('throws error if last value on stack is not a bool', function (assert) {
  assert.throws(function () {
  var o = WWW_Applet.run([
    1, 'and', [true]
  ]);
  }, /Stack value is not a Boolean: Number: 1/);
});

QUnit.test('throws if last value of args is not a bool', function (assert) {
  assert.throws(function () {
    var o = WWW_Applet.run([
      true, 'and', [2]
    ]);
  }, /Arg is not a Boolean: Number: 2/);
});

QUnit.test('it places true on stack if both conditions are true', function (assert) {
  var o = WWW_Applet.run([
    true, 'and', [6, 'equal', [6]]
  ]);
  assert.equal(_.last(o.stack), true);
});

QUnit.test('it places false on stack if first condition is false', function (assert) {
  var o = WWW_Applet.run([
    false, 'and', [6, 'equal', [6]]
  ]);
  assert.deepEqual(o.stack, [false, false]);
});

QUnit.test('it places false on stack if second condition is false', function (assert) {
  var o = WWW_Applet.run([
    true, 'and', [6, 'equal', [7]]
  ]);
  assert.deepEqual(o.stack, [true, false]);
});

QUnit.test('does not evaluate args if right-hand value is false', function (assert) {
  var o = WWW_Applet.run([
    false, 'and', ['unknown method', []]
  ]);
  assert.deepEqual(o.stack, [false, false]);
});


// ==================================================================
QUnit.module('or');
// ==================================================================

QUnit.test('it throws an error if first condition is not a bool', function (assert) {
  assert.throws(function () {
    WWW_Applet.run(["something", 'or', [false]]);
  }, /Stack value is not a Boolean: String: something/);
});

QUnit.test('it throws an error if second condition is not a bool', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([false, 'or', [false, "something"]]);
  }, /Arg is not a Boolean: String: something/);
});

QUnit.test('it places true on stack if both conditions are true', function (assert) {
  var o = WWW_Applet.run([
    true, 'or', [6, 'equal', [6]]
  ]);
  assert.deepEqual(o.stack, [true, true]);
});

QUnit.test('it places true on stack if: true or false', function (assert) {
  var o = WWW_Applet.run([
    true, 'or', [9, 'equal', [6]]
  ]);
  assert.deepEqual(o.stack, [true, true]);
});

QUnit.test('it places true on stack if: false or true', function (assert) {
  var o = WWW_Applet.run([
    false, 'or', [9, 'equal', [9]]
  ]);
  assert.deepEqual(o.stack, [false, true]);
});

QUnit.test('does not evaluate args if first condition is true', function (assert) {
  var o = WWW_Applet.run([
    true, 'or', ['no known method', []]
  ]);
  assert.deepEqual(o.stack, [true, true]);
});


// ==================================================================
QUnit.module('if true');
// ==================================================================

QUnit.test('throws an error if righ hand value is not a bool', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      6, "if true", [5]
    ]);
  }, /Stack value is not a Boolean: Number: 6/);
});

QUnit.test('does not place a value on stack', function (assert) {
  var o = WWW_Applet.run([
    true, "if true", [
      100
    ]
  ]);

  assert.deepEqual(o.stack, [true]);
});

QUnit.test('does not run tokens if stack value is false', function (assert) {
  var o = WWW_Applet.run([
    false, "if true", [
      "something unknown", []
    ]
  ]);

  assert.deepEqual(o.stack, [false]);
});


// ==================================================================
QUnit.module('if false');
// ==================================================================

QUnit.test('throws an error if righ hand value is not a bool', function (assert) {
  assert.throws(function () {
    WWW_Applet.run([
      7, "if false", [5]
    ]);
  }, /Stack value is not a Boolean: Number: 7/);
});

QUnit.test('does not place a value on stack', function (assert) {
  var o = WWW_Applet.run([
    false, "if false", [ 100 ]
  ]);

  assert.deepEqual(o.stack, [false]);
});

QUnit.test('does not run tokens if stack value is true', function (assert) {
  var o = WWW_Applet.run([
    true, "if false", [ "something unknown", [] ]
  ]);

  assert.deepEqual(o.stack, [true]);
});


// ==================================================================
QUnit.module('on click');
// ==================================================================

QUnit.test('adds event to element', function (assert) {

  $('#event').html(
    '\
      <div class="the_box">                       \
        <div><div>                                \
          <button class="submit">Submit</button>  \
          <button class="cancel">Cancel</button>  \
        </div></div>                              \
      </div>                                      \
    '
  );

  var event = WWW_Applet.run([

    'focus on', ['#event button.submit'],
    'on click', [
      'focus on ancestor', ['div.the_box'],
      'run event', ['add red']
    ],

    'focus on', ['#event div.the_box'],
    'on', [ 'add red',
      'add class', ['red']
    ]

  ]); // ======================

  $('#event button.submit').trigger('click');
  assert.equal($('#event div.the_box').hasClass('red'), true);

}); // === adds event to element


// ==================================================================
QUnit.module('forms');
// ==================================================================

QUnit.test('throws error if url contains invalid char: :', function (assert) {
  $('#form_1').attr('action', 'javascrip://alert');
  assert.throws(function () {
    WWW_Applet.run([
      'focus on', ['#form_1'],
      'submit', []
    ]);
  }, /Invalid chars in #form_1 action: javascript:/);
});

QUnit.test('throws error if url contains invalid char: &', function (assert) {
  $('#form_1').attr('action', 'javascript&amp//alert');
  assert.throws(function () {
    WWW_Applet.run([
      'focus on', ['#form_1'],
      'submit', []
    ]);
  }, /Invalid chars in #form_1 action: javascript&amp/);
});

QUnit.test('throws error if url contains invalid char: ;', function (assert) {
  $('#form_1').attr('action', 'http;amp//alert');
  assert.throws(function () {
    WWW_Applet.run([
      'focus on', ['#form_1'],
      'submit', []
    ]);
  }, /Invalid chars in #form_1 action: http;amp/);
});


QUnit.asyncTest('submits form values', function (assert) {
  expect(1);

  $('#form_1').attr('action', '/repeat/vals');

  var env = WWW_Applet.run([
    'focus on', ['#form_1'],
    'on', ['success', 'log', ['var', ['vals']]],
    'submit', []
  ]);

  var when = function () {
    return $('#form_1').hasClass('submitted');
  }; // function

  var do_this = function () {
    assert.deepEqual(_.last(env.log), {val_1: '1', val_2: '2', val_3: '3'});
    QUnit.start();
  }; // function

  when_do_this(when, do_this);
});

