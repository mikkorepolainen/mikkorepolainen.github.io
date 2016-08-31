---
layout: document
title: Javascript Promises
description: Notes about promises in javascript
modified: 2016-08-31 23:59:00
relativeroot: ../../
permalink: documents/javascript-promises
type: document
tags:
- JavaScript
- Async
- Promise
category: documents
published: true
hidden: true
---

Other JS stuff:

new Date().toISOString()

http://stackoverflow.com/questions/5311334/what-is-the-purpose-of-node-js-module-exports-and-how-do-you-use-it
http://raymondjulin.com/2014/05/10/writing-solid-asynchronous-code-using-promises/
http://stackoverflow.com/questions/762011/let-keyword-vs-var-keyword

https://www.toptal.com/nodejs/top-10-common-nodejs-developer-mistakes
- debug
- supervisor

TODO long truncation issue
TODO angular localstorage dates getting converted to strings
TODO working with/without timezones in angular

Read these

- http://bluebirdjs.com/docs/getting-started.html
- http://bluebirdjs.com/docs/api/promise.promisify.html
- https://developers.google.com/web/fundamentals/primers/promises/ same as http://www.html5rocks.com/en/tutorials/es6/promises/
- http://www.codelord.net/2015/09/24/$q-dot-defer-youre-doing-it-wrong/
- https://github.com/domenic/promises-unwrapping/blob/master/docs/states-and-fates.md
- ES6: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise NO SUPPORT IN IE
- https://pouchdb.com/2015/05/18/we-have-a-problem-with-promises.html
- http://www.mattgreer.org/articles/promises-in-wicked-detail/
- http://www.datchley.name/es6-promises/
- http://de.slideshare.net/domenicdenicola/callbacks-promises-and-coroutines-oh-my-the-evolution-of-asynchronicity-in-javascript

Libraries

- http://bluebirdjs.com
- https://github.com/tildeio/rsvp.js
- https://docs.angularjs.org/api/ng/service/$q
- A polyfill for ES6-style Promises https://github.com/stefanpenner/es6-promise

TODO

- What is Promises/A+ https://promisesaplus.com/ https://www.promisejs.org/
- Where does ES6-Promises stand now?
- Progress reporting
- Race (vs. all)

Node.js Bluebird example
===================

Error handling with multiple chained operations and throwing errors

TODO check chaining and error handling from https://developers.google.com/web/fundamentals/primers/promises/ same as http://www.html5rocks.com/en/tutorials/es6/promises/

```
var Promise = require("bluebird");

function successfulOperation() {
  console.log("successfulOperation");
  //return; // Causes TypeError: Cannot read property 'then' of undefined -> must always either resolve or reject.
  //return Promise.resolve(); // Works; result value is undefined
  return Promise.resolve("success");
}

function multipleSuccessfulOperations() {
  console.log("multipleSuccessfulOperations");
  var operations = [];
  for (let i = 0; i < 10; i++)
  {
    let msg = "success" + i;
    operations.push(new Promise(function(resolve, reject){
      //console.log(msg);
      resolve(msg);
    }));
  }
  return Promise.all(operations);
}

function unsuccesfulOperation() {
  console.log("unsuccesfulOperation");
  //throw "error"; // Crashes if not handled properly
  return Promise.reject("error"); // Crashes with "unhandled rejection" if not handled properly
}

successfulOperation()
//.then(unsuccesfulOperation()) // Does not work because function call does not return a promise
//.then(unsuccesfulOperation) // This works as long as no arguments are required
//.then(function() { return unsuccesfulOperation(); }) // Use this if arguments are required
.then(multipleSuccessfulOperations) // If this call is removed, then the next function gets the return value of successfulOperation instead
.then(function(val)
{
  console.log("Result: ", val);
})
.catch(function(err)
{
  console.error("Error: ", err);
});

```

TODO catching in between
